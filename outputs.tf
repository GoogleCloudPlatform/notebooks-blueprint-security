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

# used for testing
output "caip_sa_email" {
  description = "email of the SA used by CAIP; should not be a default SA"
  value       = google_service_account.sa_p_notebook_compute.email
}

# used for testing
output "notebook_instances" {
  description = "list of notebooks created (vm names)"
  value       = [for nbk in google_notebooks_instance.caip_nbk_p_trusted : nbk.name]
}

# used for testing
output "script_name" {
  description = "name of the post startup script installed"
  value       = format("%s/%s", module.bootstrap.bucket.url, google_storage_bucket_object.postscript.name)
}

# used for testing
output "notebook_key_name" {
  description = "name of the key used in the notebooks."
  value       = module.kms_data.keys[var.notebook_key_name]
}

# used for testing
output "notebook_key_ring_name" {
  description = "name of keyring"
  value       = module.kms_data.keyring_name
}

# used for testing
output "bkt_notebooks_name" {
  description = "name of bootstrap bucket"
  value       = module.bootstrap.bucket.name
}

# used for testing
output "folder_trusted" {
  description = "folder that holds all the trusted projects and constraints"
  value       = local.folder_trusted
}

# used for testing
output "vpc_perimeter_resource_protected" {
  description = "list of projects included in the VPC-Sc perimeter"
  value = [
    "${data.google_project.trusted_data.number}",
    "${data.google_project.trusted_analytics.number}",
    "${data.google_project.trusted_kms.number}",
  ]
}

# used for testing
output "access_level_name" {
  description = "access level name used in the perimeter policy"
  value       = module.access_level_members_higher_trust.name
}

# used for testing
output "perimeter_name" {
  description = "vpc-sc perimeter name"
  value       = format("higher_trust_notebooks_%s", random_string.random_name.result)
}
