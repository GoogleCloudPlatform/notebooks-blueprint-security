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

# Top-level folder under an organization.
resource "google_folder" "fldr_trusted" {
  display_name = var.folder_trusted
  parent       = var.parent_env
}

# enable this org policy before creation of any project to prevent default networks and firewall rules
resource "google_folder_organization_policy" "network_policy_pre" {
  folder     = google_folder.fldr_trusted.name
  constraint = "compute.skipDefaultNetworkCreation"

  boolean_policy {
    enforced = true
  }
  depends_on      = [google_folder.fldr_trusted]  
}

resource "google_project" "prj_trusted_data" {
  name            = var.project_trusted_data
  project_id      = var.project_trusted_data
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account

  depends_on      = [google_folder_organization_policy.network_policy_pre]
}

resource "google_project" "prj_trusted_analytics" {
  name            = var.project_trusted_analytics
  project_id      = var.project_trusted_analytics
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account
  depends_on      = [google_folder_organization_policy.network_policy_pre]
}

resource "google_project" "prj_trusted_data_etl" {
  name            = var.project_trusted_data_etl
  project_id      = var.project_trusted_data_etl
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account
  depends_on      = [google_folder_organization_policy.network_policy_pre]
}

# TODO The parent env should be the boot project
resource "google_project" "prj_kms" {
  name            = var.project_trusted_kms
  project_id      = var.project_trusted_kms
  folder_id       = var.bootstrap_env
  billing_account = var.billing_account
  depends_on      = [google_folder_organization_policy.network_policy_pre]
}
