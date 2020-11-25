/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

# Provides resource manager, folder structure, and org level settings
module "structure" {
  source                    = "../modules/structure"
  parent_env                = var.parent_env
  bootstrap_env             = var.bootstrap_env
  billing_account           = var.billing_account
  folder_trusted            = var.folder_trusted
  project_trusted_analytics = var.project_trusted_analytics
  project_trusted_data      = var.project_trusted_data
  project_trusted_data_etl  = var.project_trusted_data_etl
  project_trusted_kms       = var.project_trusted_kms
  terraform_sa_email        = var.terraform_sa_email
}

module "orgpolicies" {
  source = "../modules/orgpolicies"
  folder_trusted     = module.structure.high_trust_folder
  resource_locations = var.resource_locations
  vpc_subnets_projects_allowed = ["under:projects/${var.project_trusted_analytics}"]

  # org policies need to be run early on in stand alone mode to prevent permissive defaults such as default SA, default networks, and firewall rules
  depends_on = [google_service_account.sa_p_notebook_compute,
                module.structure]
}

resource "google_project_service" "enable_services_trusted_data" {
  project  = var.project_trusted_data
  for_each = toset(var.enable_services_data)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on                 = [module.structure]
}

resource "google_project_service" "enable_services_trusted_data_etl" {
  project  = var.project_trusted_data_etl
  for_each = toset(var.enable_services_data_etl)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on                 = [module.structure]
}

resource "google_project_service" "enable_services_trusted_analytics" {
  project  = var.project_trusted_analytics
  for_each = toset(var.enable_services_analytics)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on                 = [module.structure]
}

resource "google_project_service" "enable_services_trusted_networks" {
  project  = var.project_networks
  for_each = toset(var.enable_services_networks)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on                 = [module.structure]
}

resource "google_project_service" "enable_services_trusted_kms" {
  project  = var.project_trusted_kms
  for_each = toset(var.enable_services_kms)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on                 = [module.structure]
}

# Configure the networks for the CAIP Notebooks
module "network" {
  source     = "../modules/network"
  project_id = var.project_networks
  region     = var.region_trusted_network

  depends_on                 = [module.structure,
                                module.orgpolicies]
}

# Configures the firewall rules in the higher trust environment
module "firewall" {
  source     = "../modules/firewall"
  project_id = var.project_networks
  vpc_name   = module.network.vpc_trusted_private
  depends_on = [module.network,
                module.structure]
}

# Provides data governance controls such as KMS and secrets
module "data_governance" {
  source          = "../modules/data_governance"
  project_kms     = var.project_trusted_kms
  project_secrets = var.project_trusted_kms
  region          = var.region
  depends_on                 = [module.structure,
                                google_project_service.enable_services_trusted_kms,
                                module.orgpolicies]
}

# Configures data resources holding PII information
module "data" {
  source                    = "../modules/data"
  project_trusted_data      = var.project_trusted_data
  project_trusted_data_etl  = var.project_trusted_data_etl
  project_bootstrap         = var.project_trusted_kms
  project_trusted_analytics = var.project_trusted_analytics
  region                    = var.region
  key_confid_data           = module.data_governance.key_confid_data
  key_confid_etl            = module.data_governance.key_confid_etl
  confid_users              = var.confid_users
  key_bq_confid_members = [
    "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
  ]
  restricted_viewer_role = google_project_iam_custom_role.role_restricted_data_viewer.name
  depends_on = [
    module.network,
    module.structure,
    google_project_service.enable_services_trusted_data,
    module.orgpolicies    
  ]
}

# Configures the notebooks as well as startup scripts
module "notebooks" {
  source              = "../modules/notebooks"
  project_id          = var.project_trusted_analytics
  zone                = var.zone
  caip_users          = var.caip_users
  caip_sa_email       = google_service_account.sa_p_notebook_compute.email
  bucket_bootstrap    = module.data.bkt_p_bootstrap_notebook
  vpc_trusted_private = module.network.vpc_trusted_private
  sb_trusted_private  = module.network.subnet_trusted_private
  key_confid_data     = module.data_governance.key_confid_data
  depends_on = [
    module.data,
    module.structure, 
    module.orgpolicies, 
    google_project_service.enable_services_trusted_analytics
  ]
}

# Creates a VPC service perimeter.  Should enable at the end after notebooks are configured
module "perimeters" {
  source             = "../modules/perimeters"
  org                = var.org
  policy_name        = var.default_policy_name
  region             = var.region
  resources          = [
                         module.structure.perimeter_project_trusted_data_name,
                         module.structure.perimeter_project_trusted_data_etl_name,
                         module.structure.perimeter_project_trusted_analytics_name,
                         module.structure.perimeter_project_kms_name
                       ]
  ip_subnetworks     = var.perimeters_ip_subnetworks
  terraform_sa_email = var.terraform_sa_email

  depends_on = [
    module.structure,
    module.notebooks,
    module.orgpolicies,
    module.network,
    module.data,
    module.data_governance
  ]
}
