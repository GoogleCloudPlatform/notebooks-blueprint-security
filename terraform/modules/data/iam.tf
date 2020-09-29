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

#====
#IAM - add group binding for scientists.  the notebook's VM SA will already have access
#TODO expose the group name from CIP
#TODO do we move into an IAM specific module?
#====
resource "google_bigquery_dataset_iam_binding" "iam_bq_confid_viewer" {
  dataset_id = google_bigquery_dataset.bq_p_confid_dataset.dataset_id
  role       = "roles/bigquery.dataViewer"
  project    = var.project_trusted_data

  members = var.confid_users
}

//=====================================================================
// Get Service Accounts for all data services
//=====================================================================
data "google_bigquery_default_service_account" "bq_default_account" {
  project = var.project_trusted_data
}

// get the GCS default service account for the data project
data "google_storage_project_service_account" "gcs_default_account_data" {
  project = var.project_trusted_data
}

// get the GCS default service account for the ETL project
data "google_storage_project_service_account" "gcs_default_account_etl" {
  project = var.project_trusted_data_etl
}

// get the GCS default service account for the bootstrap project
data "google_storage_project_service_account" "gcs_default_account_bootstrap" {
  project = var.project_bootstrap
}

# TODO somehow need to get the SA used by CAIP service's identity used to create compute
# // get the GCS default service account for the bootstrap project
data "google_compute_default_service_account" "gce_default_account_analytics" {
  project = var.project_trusted_analytics
}

// get the notebook service account
//TODO remove hardcoded SA account name (have to split the @ out)
// data "google_service_account" "sa_notebook" {
//   account_id = "sa-p-notebook-compute"
//   project    = var.project_trusted_analytics
// }

data "google_project" "project_analytics" {
  project_id    = var.project_trusted_analytics
}

//=====================================================================
// Grant access to KMS to support CMEK for data services
// This is fine grain limited to only the single key.
// 
// need the trusted scientists
// need the CAIP service's identity granted access
//=====================================================================
resource "google_kms_crypto_key_iam_binding" "iam_p_bq_sa_confid" {
  crypto_key_id = var.key_confid_data
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = concat(
    [
      "serviceAccount:${data.google_bigquery_default_service_account.bq_default_account.email}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_data.email_address}",
      "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_bootstrap.email_address}",
      "serviceAccount:${data.google_compute_default_service_account.gce_default_account_analytics.email}",
      "serviceAccount:service-${data.google_project.project_analytics.number}@compute-system.iam.gserviceaccount.com",
    ],
    var.key_bq_confid_members,
    var.confid_users
  )
}

resource "google_kms_crypto_key_iam_binding" "iam_p_gcs_sa_confid_etl" {
  crypto_key_id = var.key_confid_etl
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_etl.email_address}"
  ]
}