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

# externalized for testing
output "notebook_instance_names" {
  description = "reference object of notebooks"
  value = [
    for instance in google_notebooks_instance.caip_nbk_p_eeee_confid :
    chomp(instance.name)
  ]
}

output "notebook_script_name" {
  description = "reference object of notebooks"
  value = [
    for instance in google_notebooks_instance.caip_nbk_p_eeee_confid :
    chomp(instance.post_startup_script)
  ]
}
