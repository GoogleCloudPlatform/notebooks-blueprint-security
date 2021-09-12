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


output "caip_sa_email" {
  description = "Email of the SA used by Cloud AI Platform; should not be a default SA."
  value       = module.notebook.caip_sa_email
}

output "notebook_instances" {
  description = "List of notebooks created (vm names)."
  value       = module.notebook.notebook_instances
}

output "script_name" {
  description = "Name of the post startup script installed."
  value       = module.notebook.script_name
}

output "notebook_key_name" {
  description = "Key name used to protect notebooks."
  value       = module.notebook.notebook_key_name
}

output "bkt_notebooks_name" {
  description = "Name of bootstrap bucket."
  value       = module.notebook.bkt_notebooks_name
}

output "notebook_key_ring_name" {
  description = "Name of keyring protecting notebooks."
  value       = module.notebook.notebook_key_ring_name
}

output "resource_locations" {
  description = "Name of regions expected in org policy."
  value       = local.resource_locations
}

output "folder_trusted" {
  description = "Folder that holds all the trusted projects and constraints."
  value       = module.notebook.folder_trusted
}

output "vpc_perimeter_protected_resources" {
  description = "List of projects included in the VPC-SC perimeter."
  value       = module.notebook.vpc_perimeter_resource_protected
}

output "default_policy_id" {
  description = "Access level policy id (i.e organization id)."
  value       = var.default_policy_id
}

output "perimeter_name" {
  description = "Perimeter name used to protect the notebooks."
  value       = module.notebook.perimeter_name
}

output "access_level_name" {
  description = "Access level policy name."
  value       = module.notebook.access_level_name
}

