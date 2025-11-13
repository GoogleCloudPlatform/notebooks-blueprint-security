/**
 * Copyright 2021 Google LLC
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
# OSLogin User role and SSH into the notebook
resource "google_service_account" "sa_p_notebook_compute" {
  project      = var.project_trusted_analytics
  account_id   = format("sa-p-notebook-compute-%s", random_string.random_name.result)
  display_name = "Notebooks in trusted environment"
}

# We are giving privileges to the notebook-compute service account
# Compute: compute.instanceAdmin
#    - gce instance administration, shieldedVM, osLogin
# Data
#   - Big Query: roles/bigquery.dataViewer
#       - read data
#   - Big Query: roles/bigquery.jobuser
#       - run BQ jobs and queries
#   - (optional) Storage: roles/storage.objectAdmin
#       - create and destroy temporary buckets to manage state
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

# create custom role from dataViewer that doesn't allow export
module "role_restricted_data_viewer" {
  source  = "terraform-google-modules/iam/google//modules/custom_role_iam"
  version = "~> 8.0"

  target_level = "project"
  target_id    = var.project_trusted_data
  role_id      = format("blueprint_restricted_data_viewer_%s", random_string.random_name.result)
  title        = format("Blueprint restricted Data Viewer %s", random_string.random_name.result)
  description  = "BQ Data Viewer role with export removed"
  base_roles   = ["roles/bigquery.dataViewer"]
  permissions  = []
  excluded_permissions = [
    "bigquery.tables.export",
    "bigquery.models.export",
    "resourcemanager.projects.list",
  ]
  members = []
}

# IAM - add group binding for scientists.  the notebook's VM SA will already have access
resource "google_bigquery_dataset_iam_binding" "iam_bq_confid_viewer" {
  dataset_id = var.dataset_id
  role       = format("projects/%s/roles/%s", var.project_trusted_data, module.role_restricted_data_viewer.custom_role_id)
  project    = var.project_trusted_data

  members = concat(var.confidential_groups, ["serviceAccount:${google_service_account.sa_p_notebook_compute.email}"])
}

#=====================================================================
# Get Service Accounts for all data services
#=====================================================================
data "google_bigquery_default_service_account" "bq_default_account" {
  project = var.project_trusted_data
}

# get the GCS default service account for the data project
data "google_storage_project_service_account" "gcs_default_account_data" {
  project = var.project_trusted_data
}

# get the GCS default service account for the project holding bootstrap code
data "google_storage_project_service_account" "gcs_default_account_bootstrap" {
  project = var.project_trusted_kms
}

# get the GCS default service account for the bootstrap project
data "google_compute_default_service_account" "gce_default_account_analytics" {
  project = var.project_trusted_analytics
}

data "google_project" "project_analytics" {
  project_id = var.project_trusted_analytics
}

#=====================================================================
# Grant access to KMS to support CMEK for data services
# This is fine grain limited to only the single key.
#
# config_users: a group with trusted scientists identities.  Add users in this group.
# google_managed_members: need the AI Platform's service's identity granted access.  Do not add identities to this group
#=====================================================================
resource "google_kms_crypto_key_iam_binding" "iam_p_bq_sa_confid" {
  crypto_key_id = module.kms_data.keys[var.notebook_key_name]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = concat(
    [
      "serviceAccount:${data.google_bigquery_default_service_account.bq_default_account.email}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_data.email_address}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_bootstrap.email_address}",
      "serviceAccount:${data.google_compute_default_service_account.gce_default_account_analytics.email}",
      "serviceAccount:service-${data.google_project.project_analytics.number}@compute-system.iam.gserviceaccount.com",
    ],
    ["serviceAccount:${google_service_account.sa_p_notebook_compute.email}"],
    var.confidential_groups
  )
}

# allow google managed service account for notebooks to access subnet in the shared project
data "google_compute_subnetwork" "trusted_notebook_subnetwork" {
  project = split("/", var.trusted_private_subnet)[1]
  region  = split("/", var.trusted_private_subnet)[3]
  name    = split("/", var.trusted_private_subnet)[5]
}

resource "google_compute_subnetwork_iam_binding" "subnet_binding" {
  project    = data.google_compute_subnetwork.trusted_notebook_subnetwork.project
  region     = data.google_compute_subnetwork.trusted_notebook_subnetwork.region
  subnetwork = data.google_compute_subnetwork.trusted_notebook_subnetwork.name
  role       = "roles/compute.networkAdmin"
  members = [
    format("serviceAccount:service-%s@gcp-sa-notebooks.iam.gserviceaccount.com", data.google_project.trusted_analytics.number),
  ]
}
