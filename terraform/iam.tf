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

# The notebook-compute-sa provides the underlying policies that the compute uses to access other resources
# within the project for the data scientist.  
#
# The data scientist should not be given the ability to become an SA.  Instead, they should be given
# OSLogin role and SSH into the notebook
resource "google_service_account" "sa_p_notebook_compute" {
  project      = var.project_trusted_analytics
  account_id   = "sa-p-notebook-compute"
  display_name = "Notebooks in trusted environment"
}

# We are giving privileges to the notebook-compute service account
# Compute: compute.instanceAdmin
#    - gce instance adminsitration, shieldedVM, osLogin
# Data
#   - Big Query: roles/bigquery.dataViewer
#       - read data
#   - Big Query: roles/bigquery.jobuser
#       - run BQ jobs and queries
#   - (optional) Storage: roles/storage.objectAdmin
#       - create and destroy temporary buckets to manage state
#   - Pub/Sub: @TODO
#       - receive de-id values for analysis
# Notebooks: roles/notebooks.admin
resource "google_project_iam_member" "notebook_instance_compute" {
  project = var.project_trusted_analytics
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
}

resource "google_project_iam_member" "notebook_instance_bq_job" {
  project = var.project_trusted_analytics
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
}

resource "google_project_iam_member" "notebook_instance_bq_session" {
  project = var.project_trusted_analytics
  role    = "roles/bigquery.readSessionUser"
  member  = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
}

resource "google_project_iam_member" "notebook_instance_caip" {
  project = var.project_trusted_analytics
  role    = "roles/notebooks.admin"
  member  = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
}
