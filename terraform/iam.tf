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
# The data scientiest should not be given the ability to become an SA.  Instead, they should be given
# OSLogin role and SSH into the notebook
resource "google_service_account" "sa_p_notebook_compute" {
  project      = var.project_trusted_analytics
  account_id   = "sa-p-notebook-compute"
  display_name = "Notebooks in trusted environment"

  depends_on = [module.structure]
}


# grant trusted data scientists the ability to access notebooks thru UI
# established through IAP.
resource "google_service_account_iam_binding" "iam_trusted_scientists" {
  service_account_id = google_service_account.sa_p_notebook_compute.name
  role               = "roles/iam.serviceAccountUser"

  members = var.trusted_scientists
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

// create custom role from dataViewer that doesn't allow export
// Note: resourcemanager.projects.list is not applicable at project level, but is assigned in the BQ DataViewer predefined role (org level)
resource "google_project_iam_custom_role" "role_restricted_data_viewer" {
  project     = var.project_trusted_analytics
  role_id     = "eeee_restricted_data_viewer"
  title       = "Restricted Data Viewer"
  description = "BQ Data Viewer role with export removed"
  permissions = [
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.models.getData",
    "bigquery.models.getMetadata",
    "bigquery.models.list",
    "bigquery.routines.get",
    "bigquery.routines.list",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.list",
    "resourcemanager.projects.get"
  ]
}

resource "google_project_iam_member" "notebook_instance_bq" {
  project = var.project_trusted_analytics
  role    = google_project_iam_custom_role.role_restricted_data_viewer.name
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

#TODO add pub/sub role

# (optional) uncomment this block, if you desire your data scientest to have code within their notebooks
# that can create a temporary gcs bucket
# resource "google_project_iam_member" "notebook-instance-gcs" {
#   project = var.project
#   role    = "roles/storage.objectAdmin"
#   member  = "serviceAccount:${google_service_account.notebook-compute-sa.email}"
# }
