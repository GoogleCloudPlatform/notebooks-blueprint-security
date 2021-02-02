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

module "standalone_example" {
  source     = "../../../examples/standalone_example"

  zone                     = var.zone
  vpc_perimeter_ip_subnetworks    = var.vpc_perimeter_ip_subnetworks
  default_policy_id         = var.default_policy_id
  project_trusted_analytics = var.project_trusted_analytics
  project_trusted_data      = var.project_trusted_data
  project_trusted_kms       = var.project_trusted_kms
  trusted_private_network   = var.trusted_private_network
  trusted_private_subnet    = var.trusted_private_subnet
  caip_users                = var.caip_users
  confid_users              = var.confid_users
  trusted_scientists        = var.trusted_scientists
  dataset_id                = var.dataset_id
}
