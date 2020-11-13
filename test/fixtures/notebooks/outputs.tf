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

output "zone" {
  description = "zone where notebooks exist"
  value       = var.zone
}

output "notebook_instances" {
  description = "list of notebooks created (vm names)"
  value       = module.notebooks.notebook_instance_names
}

output "caip_sa_email" {
  description = "email of the SA used by CAIP; should not be a default SA"
  value       = var.caip_compute_sa_email
}

output "script_name" {
  description = "name of the post startup script installed"
  value       = module.notebooks.notebook_script_name
}

output "notebook_key_name" {
  description = "name of the post startup script installed"
  value       = module.data_governance.key_confid_data
}
