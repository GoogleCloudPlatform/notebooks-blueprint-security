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

locals {
  region = split("-", var.zone)[0]
}

module "orgpolicies" {
  source                       = "./modules/orgpolicies"
  folder_trusted               = "folders/${data.google_project.trusted_analytics.folder_id}"
  resource_locations           = var.resource_locations
  vpc_subnets_projects_allowed = ["under:projects/${var.project_trusted_analytics}"]

  # only configure org policies after all SA's have been created
  depends_on = [google_service_account.sa_p_notebook_compute]
}

resource "google_project_service" "enable_services_trusted_data" {
  project  = var.project_trusted_data
  for_each = toset(var.enable_services_data)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "enable_services_trusted_data_etl" {
  project  = var.project_trusted_data_etl
  for_each = toset(var.enable_services_data_etl)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "enable_services_trusted_analytics" {
  project  = var.project_trusted_analytics
  for_each = toset(var.enable_services_analytics)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "enable_services_trusted_kms" {
  project  = var.project_trusted_kms
  for_each = toset(var.enable_services_kms)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# The key ring holds data keys that encrypt any PII data at rest such as BQ, GCS, or boot images
# Initial key is HSM backed key rotates every 45 days
module "kms_data" {
  source               = "terraform-google-modules/kms/google"
  project_id           = var.project_trusted_kms
  location             = local.region
  keyring              = "trusted-data-keyring"
  keys                 = [var.data_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = "3888000s" # 45 days
}

# The key ring holds ephemeral keys that protect transitory data as it is being transformed.
# Initial key is software backed key rotates every 10 days
# These keys have a shorter rotation period due to volume of expected data.
module "kms_ephemeral" {
  source               = "terraform-google-modules/kms/google"
  project_id           = var.project_trusted_kms
  location             = local.region
  keyring              = "trusted-ephemeral-keyring"
  keys                 = [var.data_etl_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = "864000s" # 10 days
}

# Configures data resources holding PII information
module "data" {
  source                    = "./modules/data"
  project_trusted_data      = var.project_trusted_data
  project_trusted_data_etl  = var.project_trusted_data_etl
  project_bootstrap         = var.project_trusted_kms
  project_trusted_analytics = var.project_trusted_analytics
  region                    = local.region
  key_confid_data           = module.kms_data.keys[var.data_key_name]
  key_confid_etl            = module.kms_ephemeral.keys[var.data_etl_key_name]
  confid_users              = var.confid_users
  key_bq_confid_members = [
    "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
  ]
  restricted_viewer_role = google_project_iam_custom_role.role_restricted_data_viewer.name
  depends_on = [
    module.kms_data,
  ]
}

# Configures the notebooks as well as startup scripts
module "notebooks" {
  source                  = "./modules/notebooks"
  project_id              = var.project_trusted_analytics
  zone                    = var.zone
  caip_users              = var.caip_users
  caip_sa_email           = google_service_account.sa_p_notebook_compute.email
  bucket_bootstrap        = module.data.bkt_p_bootstrap_notebook
  trusted_private_network = var.trusted_private_network
  trusted_private_subnet  = var.trusted_private_subnet
  key_confid_data         = module.kms_data.keys[var.data_key_name]
  depends_on = [
    module.data
  ]
}

# Create a VPC service control perimeter.  Enable at the end after notebooks are configured.
module "org_policy" {
  source      = "terraform-google-modules/vpc-service-controls/google"
  parent_id   = var.default_policy_id
  policy_name = var.vpc_perimeter_policy_name
}

module "access_level_members_higher_trust" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  policy         = module.org_policy.policy_id
  name           = "higher_trust_notebooks_members"
  members        = [format("serviceAccount:%s", var.terraform_sa_email)]
  ip_subnetworks = var.vpc_perimeter_ip_subnetworks

  # Note: Below are additional policy attributes you should configure based on your security policies, which are additional context information part of endpoint verification configuration.
  # regions                     = var.vpc_perimeter_regions
  # allowed_encryption_statuses = ["ENCRYPTED"]
  # require_corp_owned          = true
  # require_screen_lock         = true
}

data "google_project" "trusted_data" {
  project_id = var.project_trusted_data
}

data "google_project" "trusted_analytics" {
  project_id = var.project_trusted_analytics
}

data "google_project" "trusted_data_etl" {
  project_id = var.project_trusted_data_etl
}

data "google_project" "trusted_kms" {
  project_id = var.project_trusted_kms
}

module "regular_service_perimeter_higher_trust" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  policy         = module.org_policy.policy_id
  perimeter_name = "higher_trust_notebooks"
  description    = "Perimeter shielding Notebook projects with PII data"
  resources = [
    "projects/${data.google_project.trusted_data.number}",
    "projects/${data.google_project.trusted_analytics.number}",
    "projects/${data.google_project.trusted_data_etl.number}",
    "projects/${data.google_project.trusted_kms.number}",
  ]
  access_levels = [module.access_level_members_higher_trust.name]
  restricted_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "notebooks.googleapis.com",
    "bigquery.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]

  depends_on = [
    module.notebooks
  ]
}
