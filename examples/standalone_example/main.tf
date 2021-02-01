/*
Copyright 2021 Google LLC

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

# append all resource names to help with testing
# buckets must be all lowercase for buckets
resource "random_string" "random_name" {
  length    = 4
  min_lower = 4
  special   = false
}

data "google_project" "trusted_analytics" {
  project_id = var.project_trusted_analytics
}

locals {
  zone               = "us-central1-a"
  region             = split("-", local.zone)[0]
  folder_trusted     = "folders/${data.google_project.trusted_analytics.folder_id}"
  bootstrap_bkt_name = format("restricted-bootstrap-nbk-%s", random_string.random_name.result)
  data_key_name      = "sample_data_key_name"
}

module "bq_data_key" {
  source               = "terraform-google-modules/kms/google"
  project_id           = var.project_trusted_kms
  location             = local.region
  keyring              = format("trusted-data-keyring-%s", random_string.random_name.result)
  keys                 = [local.data_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = "3888000s" # 45 days
}

# Configures data resources holding PII information
module "data" {
  source                    = "./data"
  project_trusted_data      = var.project_trusted_data
  project_trusted_analytics = var.project_trusted_analytics
  region                    = local.region
  dataset_name              = format("sample_pii_%s", random_string.random_name.result)
  data_key                  = module.bq_data_key.keys[local.data_key_name]
  confid_users              = var.confid_users

}

module "notebook" {
  source = "../.."

  vpc_perimeter_regions           = ["US", "DE"]
  vpc_perimeter_policy_name       = "higher_trust_perimeter_policy"
  vpc_perimeter_ip_subnetworks    = var.vpc_perimeter_ip_subnetworks
  zone                            = local.zone
  resource_locations              = ["in:us-locations", "in:eu-locations"]
  notebook_key_name               = "trusted-data-key"
  dataset_id                      = module.data.dataset_id
  notebook_name_prefix            = "trusted-sample"
  bootstrap_notebooks_bucket_name = "notebook_bootstrap"

  default_policy_id         = var.default_policy_id
  project_trusted_analytics = var.project_trusted_analytics
  project_trusted_data      = var.project_trusted_data
  project_trusted_kms       = var.project_trusted_kms
  trusted_private_network   = var.trusted_private_network
  trusted_private_subnet    = var.trusted_private_subnet
  caip_users                = var.caip_users
  confid_users              = var.confid_users
  trusted_scientists        = var.trusted_scientists
}
