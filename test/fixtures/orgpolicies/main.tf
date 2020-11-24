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

# resource "random_string" "random_fldr" {
#   length    = 4
#   min_lower = 4
#   special   = false
# }

data "google_folder" "fldr_trusted_test" {
  folder              = var.trusted_folder_id
  lookup_organization = false
}

# make a temporary trusted folder
# resource "google_folder" "fldr_trusted_test" {
#   display_name = format("eeee-%s-%s", var.folder_trusted, random_string.random_fldr.result)
#   parent       = var.parent_env
# }

module "orgpolicies" {
  source             = "../../../terraform/modules/orgpolicies"
  folder_trusted     = data.google_folder.fldr_trusted_test.name
  resource_locations = var.resource_locations

  #depends_on = [google_folder.fldr_trusted_test]
}
