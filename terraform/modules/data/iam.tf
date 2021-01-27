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

# create custom role from dataViewer that doesn't allow export
module "role_restricted_data_viewer" {
  source               = "terraform-google-modules/iam/google//modules/custom_role_iam"
  target_level         = "project"
  target_id            = var.project_trusted_data
  role_id              = "blueprint_restricted_data_viewer"
  title                = "Restricted Data Viewer"
  description          = "BQ Data Viewer role with export removed"
  base_roles           = ["roles/bigquery.dataViewer"]
  permissions          = []
  excluded_permissions = ["bigquery.tables.export"]
  members              = []
}

# IAM - add group binding for scientists.  the notebook's VM SA will already have access
resource "google_bigquery_dataset_iam_binding" "iam_bq_confid_viewer" {
  dataset_id = module.bigquery.bigquery_dataset
  role       = module.role_restricted_data_viewer.custom_role_id
  project    = var.project_trusted_data

  members = concat(var.confid_users, var.google_managed_members)
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

# get the GCS default service account for the bootstrap project
data "google_storage_project_service_account" "gcs_default_account_bootstrap" {
  project = var.project_bootstrap
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
  crypto_key_id = var.data_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = concat(
    [
      "serviceAccount:${data.google_bigquery_default_service_account.bq_default_account.email}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_data.email_address}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_bootstrap.email_address}",
      "serviceAccount:${data.google_compute_default_service_account.gce_default_account_analytics.email}",
      "serviceAccount:service-${data.google_project.project_analytics.number}@compute-system.iam.gserviceaccount.com",
    ],
    var.google_managed_members,
    var.confid_users
  )
}
