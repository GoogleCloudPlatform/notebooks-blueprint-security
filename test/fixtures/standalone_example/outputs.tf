/**
 * Copyright 2020 Google LLC
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

output "project_id" {
  description = "project holding notebooks"
  value       = var.project_trusted_analytics
}

output "kms_project_id" {
  description = "project holding keys"
  value       = var.project_trusted_kms
}

output "zone" {
  description = "zone where notebooks exist"
  value       = var.zone
}

output "caip_sa_email" {
  description = "email of the SA used by CAIP; should not be a default SA"
  value       = module.standalone_example.caip_sa_email
}

output "notebook_instances" {
  description = "list of notebooks created (vm names)"
  value       = module.standalone_example.notebook_instances
}

output "script_name" {
  description = "name of the post startup script installed"
  value       = module.standalone_example.script_name
}

output "notebook_key_name" {
  description = "name of the key used by notebook"
  value       = module.standalone_example.notebook_key_name
}

output "bkt_notebooks_project_id" {
  description = "name of the project that holds the bootstrap bucket"
  value       = var.project_trusted_kms
}

output "bkt_notebooks_name" {
  description = "name of the bootstrap bucket"
  value       = module.standalone_example.bkt_notebooks_name
}

output "notebook_key_ring_name" {
  description = "name of keyring"
  value       = module.standalone_example.notebook_key_ring_name
}

output "resource_locations" {
  description = "name of regions expected in org policy"
  value       =  module.standalone_example.resource_locations
}

output "folder_trusted" {
  description = "folder that holds all the trusted projects and constraints"
  value       = module.standalone_example.folder_trusted
}

output "vpc_perimeter_protected_resources" {
  description = "list of projects included in the VPC-Sc perimeter"
  value       =  module.standalone_example.vpc_perimeter_protected_resources
}

output "default_policy_id" {
  description = "access level policy id. (i.e organization id)"
  value       =  var.default_policy_id
}

output "perimeter_name" {
  description = "perimeter name used to protect the notebooks"
  value       =  module.standalone_example.perimeter_name
}

output "access_level_name" {
  description = "access level policy name"
  value       =  module.standalone_example.access_level_name
}
