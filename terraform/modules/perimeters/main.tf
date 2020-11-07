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

resource "random_string" "random_al" {
  length    = 4
  min_lower = 4
  special   = false
}

# Use existing default policy.
resource "google_access_context_manager_service_perimeter" "higher_trusted_perimeter_resource" {
  parent = "accessPolicies/${var.policy_name}"
  name   = format("accessPolicies/%s/servicePerimeters/sp_p_higher_trust_analytics_eeee_%s", var.policy_name, random_string.random_al.result)
  title  = format("sp_p_higher_trust_analytics_eeee_%s", random_string.random_al.result)
  status {
    restricted_services = var.restricted_services
    resources           = var.resources
    access_levels       = [google_access_context_manager_access_level.trusted_access_level.id]
  }
}

# Enable additional conditions as needed with endpoint verification by uncommenting items below
resource "google_access_context_manager_access_level" "trusted_access_level" {
  parent = "accessPolicies/${var.policy_name}"
  name   = format("accessPolicies/%s/accessLevels/alp_p_higher_trust_analytics_eeee_%s", var.policy_name, random_string.random_al.result)
  title  = format("alp_p_higher_trust_analytics_eeee_%s", random_string.random_al.result)
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
      members        = [format("serviceAccount:%s", var.terraform_sa_email)]
    }
  }
}
