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


//=====================================================================
// create datasets
//=====================================================================
resource "google_bigquery_dataset" "bq_p_confid_dataset" {
  dataset_id    = "bq_dddd_p_confid_dataset"
  friendly_name = "confid data"
  description   = "Dataset holding tables with PII"
  project       = var.project_trusted_data
  location      = var.region

  default_encryption_configuration {
    kms_key_name = var.key_confid_data
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      # Ignore changes to location since auto corrects to lowercase
      # Ignore changes to access because IAM will update as needed
      location,
      access,
    ]
  }

  depends_on = [google_kms_crypto_key_iam_binding.iam_p_bq_sa_confid]
}

resource "google_bigquery_table" "confid_table" {
  dataset_id = google_bigquery_dataset.bq_p_confid_dataset.dataset_id
  project       = var.project_trusted_data
  table_id   = "confid_table"
}

resource "google_bigquery_job" "confid_table_load" {
  project    = var.project_trusted_data
  job_id     = format("confid_table_load_%s", formatdate("YYYY_MM_DD_hh_mm_ss", timestamp()))

  load {
    source_uris = [
      "${google_storage_bucket.bkt_p_data_etl.url}/${google_storage_bucket_object.confid_data.name}",
    ]

    destination_table {
      project_id = var.project_trusted_data
      dataset_id = google_bigquery_dataset.bq_p_confid_dataset.dataset_id
      table_id   = google_bigquery_table.confid_table.table_id
    }

    skip_leading_rows = 1
    schema_update_options = ["ALLOW_FIELD_RELAXATION", "ALLOW_FIELD_ADDITION"]

    write_disposition = "WRITE_APPEND"
    autodetect = true
  }

}
