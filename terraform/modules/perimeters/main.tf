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

# Uncomment if do not have an access policy already defined
# Consider using dry-run mode to enforce the VPC-SC
// resource "google_access_context_manager_access_policy" "trusted_policy" {
//   parent = var.org
//   title  = "Trusted policy"
// }

# Use existing default policy.
resource "google_access_context_manager_service_perimeter" "higher_trusted_perimeter_resource" {
  parent = "accessPolicies/${var.policy_name}"
  name   = "accessPolicies/${var.policy_name}/servicePerimeters/sp_p_higher_trust_analytics"
  title  = "sp_p_higher_trust_analytics"
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
    access_levels = [google_access_context_manager_access_level.trusted_access_level.id]
  }
}

# Enable additional conditions as needed with endpoint verification.
resource "google_access_context_manager_access_level" "trusted_access_level" {
  parent = "accessPolicies/${var.policy_name}"
  name   = "accessPolicies/${var.policy_name}/accessLevels/alp_p_higher_trust_analytics"
  title  = "alp_p_higher_trust_analytics"
  basic {
    conditions {
    #   device_policy {
    #     require_screen_lock = true
    #     require_corp_owned = true
    #     allowed_encryption_statuses = [
    #       "ENCRYPTED"
    #     ]
    #   }
    #   regions = [upper(var.region)]
      ip_subnetworks = var.ip_subnetworks
      members = [format("serviceAccount:%s", var.terraform_sa_email)]
    }
  }
}
