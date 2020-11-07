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

output "org" {
  description = "organization id"
  value       = var.organizations
}

output "restricted_services" {
  description = "list of services within the perimeter"
  value       = var.restricted_services
}

output "policy_name" {
  description = "name of policy"
  value       = var.default_policy_name
}

output "access_level_name" {
  description = "name of access policy"
  value       = module.perimeters.access_level_name
}

output "perimeter_title" {
  description = "perimeter title"
  value       = module.perimeters.perimeter_title
}

output "resources_protected" {
  description = "list of projects protected by the perimiter"
  value       = var.perimeter_projects
}
