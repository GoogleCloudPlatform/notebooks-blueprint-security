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

# Custom module called 'structure' in the modules folder
# Provides resource manager, folder structure, and org level settings
module "structure" {
  source                    = "./modules/structure"
  for_each                  = tobool(var.enable_module_structure) == true ? toset(["1"]) : toset([])
  parent_env                = var.parent_env
  billing_account           = var.billing_account
  folder_trusted            = var.folder_trusted
  project_trusted_analytics = var.project_trusted_analytics
  project_trusted_data      = var.project_trusted_data
  project_trusted_data_etl  = var.project_trusted_data_etl
  project_trusted_kms       = var.project_trusted_kms
  terraform_sa_email        = var.terraform_sa_email
  # depends_on = [
  #   google_project_service.enable_services_trusted_analytics,
  #   google_project_service.enable_services_trusted_data,
  #   google_project_service.enable_services_trusted_data_etl,
  #   google_project_service.enable_services_trusted_kms
  # ]
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

# This module is called 'network' and is defined in the modules folder
# We are creating an instance also called 'network'
# Enables required services for the module.
module "network" {
  source     = "./modules/network"
  project_id = var.project_networks
  region     = var.region_trusted_network
  depends_on = [google_project_service.enable_services_trusted_networks]
}

module "firewall" {
  source     = "./modules/firewall"
  project_id = var.project_networks
  vpc_name   = module.network.vpc_trusted_private
  depends_on = [google_project_service.enable_services_trusted_networks]
}

# Configures perimeters.
# module "perimeters" {
#   source      = "./modules/perimeters"
#   region      = var.region
#   org         = var.org
#   policy_name = var.default_policy_name
#   resources = [
#     format("projects/%s", module.structure[1].perimeter_project_trusted_analytics_number),
#     format("projects/%s", module.structure[1].perimeter_project_trusted_data_number),
#     format("projects/%s", module.structure[1].perimeter_project_trusted_data_etl_number),
#     format("projects/%s", module.structure[1].perimeter_project_kms_number)
#   ]
#   ip_subnetworks     = var.perimeters_ip_subnetworks
#   terraform_sa_email = var.terraform_sa_email
#   depends_on = [
#     module.structure,
#     module.notebooks
#   ]
# }

# Custom module called 'data_governance' in the modules folder
# Provides data governance controls
module "data_governance" {
  source          = "./modules/data_governance"
  project_kms     = var.project_trusted_kms
  project_secrets = var.project_trusted_kms
  region          = var.region
  depends_on      = [google_project_service.enable_services_trusted_kms]
}

# Provides data controls
module "data" {
  source                    = "./modules/data"
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
  depends_on = [
    module.network,
    google_project_service.enable_services_trusted_data,
    google_project_service.enable_services_trusted_data_etl,
    google_project_service.enable_services_trusted_kms,
    google_project_service.enable_services_trusted_analytics,
  ]
}

module "notebooks" {
  source              = "./modules/notebooks"
  project_id          = var.project_trusted_analytics
  zone                = var.zone
  caip_users          = var.caip_users
  caip_sa_email       = google_service_account.sa_p_notebook_compute.email
  bucket_bootstrap    = module.data.bkt_p_bootstrap_notebook
  vpc_trusted_private = module.network.vpc_trusted_private
  sb_trusted_private  = module.network.subnet_trusted_private
  key_confid_data     = module.data_governance.key_confid_data
  depends_on = [
    google_project_service.enable_services_trusted_analytics,
    module.data
  ]
  // obj_notebook_postscript = module.data.bkt_p_bootstrap_notebook_postscript.name
}
