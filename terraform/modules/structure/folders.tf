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
  display_name = format("eeee-%s", var.folder_trusted)
  parent       = var.parent_env
}

resource "google_project" "prj_trusted_data" {
  name            = "prj-eeee-p-trusted-data"
  project_id      = var.project_trusted_data
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account
}

resource "google_project" "prj_trusted_analytics" {
  name            = "prj-eeee-p-trusted-analytics"
  project_id      = var.project_trusted_analytics
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account
}

resource "google_project" "prj_trusted_data_etl" {
  name            = "prj-eeee-p-trusted-data-etl"
  project_id      = var.project_trusted_data_etl
  folder_id       = google_folder.fldr_trusted.name
  billing_account = var.billing_account
}

# TODO The parent env should be the boot project
resource "google_project" "prj_kms" {
  name            = "prj-eeee-b-kms"
  project_id      = var.project_trusted_kms
  folder_id       = var.bootstrap_env
  billing_account = var.billing_account
}
