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

// resource "google_access_context_manager_access_policy" "trusted_policy" {
//   parent = var.org
//   title  = "Trusted policy"
// }

# Use existing default policy.
resource "google_access_context_manager_service_perimeter" "trusted_perimeter_resource" {
  parent = "accessPolicies/${var.policy_name}"
  name   = "accessPolicies/${var.policy_name}/servicePerimeters/restrict_all"
  title  = "restrict_all"
  status {
    restricted_services = [
      "compute.googleapis.com",
      "storage.googleapis.com",
      "notebooks.googleapis.com",
      "bigquery.googleapis.com",
      "datacatalog.googleapis.com",
      "dataflow.googleapis.com",
      "dlp.googleapis.com",
      "cloudkms.googleapis.com",
      "secretmanager.googleapis.com"
    ]
    resources = var.resources
  }
}

resource "google_access_context_manager_access_level" "trusted_access_level" {
  parent = "accessPolicies/${var.policy_name}"
  name   = "accessPolicies/${var.policy_name}/accessLevels/trusted_corp"
  title  = "trusted_corp"
  basic {
    conditions {
      device_policy {
        require_screen_lock = true
        require_corp_owned = true
        allowed_encryption_statuses = [
          "ENCRYPTED"
        ]
      }
      regions = []
    }
  }
}