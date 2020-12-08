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

data "google_folder" "fldr_trusted_test" {
  folder              = var.trusted_folder_id
  lookup_organization = false
}

module "orgpolicies" {
  source             = "../../../terraform/modules/orgpolicies"
  folder_trusted     = data.google_folder.fldr_trusted_test.name
  resource_locations = var.resource_locations
  vpc_subnets_projects_allowed = ["under:projects/${var.project_trusted_analytics}"]
}
