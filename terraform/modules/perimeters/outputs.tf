/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

# externalized for testing
output "access_level_name" {
  description = "name of the access level"
  value       = google_access_context_manager_access_level.trusted_access_level.name
}

# externalized for testing
output "perimeter_title" {
  description = "perimeter title (i.e short name)"
  value       = google_access_context_manager_service_perimeter.higher_trusted_perimeter_resource.title
}
