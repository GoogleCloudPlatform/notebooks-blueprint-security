/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  vpc_perimeter_regions           = ["US", "DE"]
  vpc_perimeter_policy_name       = "higher_trust_perimeter_policy"
  resource_locations              = ["in:us-locations", "in:eu-locations"]
  notebook_key_name               = "trusted-data-key"
  notebook_name_prefix            = "trusted-sample"
  bootstrap_notebooks_bucket_name = "notebook_bootstrap"

}

module "notebook" {
  source = "../.."

  vpc_perimeter_regions           = local.vpc_perimeter_regions
  vpc_perimeter_policy_name       = local.vpc_perimeter_policy_name
  vpc_perimeter_ip_subnetworks    = var.vpc_perimeter_ip_subnetworks
  zone                            = var.zone
  resource_locations              = local.resource_locations
  notebook_key_name               = local.notebook_key_name
  dataset_id                      = var.dataset_id
  notebook_name_prefix            = local.notebook_name_prefix
  bootstrap_notebooks_bucket_name = local.bootstrap_notebooks_bucket_name

  default_policy_id         = var.default_policy_id
  project_trusted_analytics = var.project_trusted_analytics
  project_trusted_data      = var.project_trusted_data
  project_trusted_kms       = var.project_trusted_kms
  trusted_private_network   = var.trusted_private_network
  trusted_private_subnet    = var.trusted_private_subnet
  confidential_groups       = var.confidential_groups
  trusted_scientists        = var.trusted_scientists
}
