/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// TODO fix the business unit 4 digit number

// TODO move the CAIP notebook startup script here
// the GCS bucket should be in the boot environment so it cannot be altered

// confid bucket is encrypted with CMEK key and with versioning
resource "google_storage_bucket" "bkt_p_confid" {
  name               = "${var.project_bootstrap}-bkt-0000-p-confid"
  project            = var.project_trusted_data
  location           = var.region
  uniform_bucket_level_access = true
  force_destroy      = true

  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = var.key_confid_data
  }
  depends_on = [google_kms_crypto_key_iam_binding.iam_p_gcs_sa_confid_etl]
}

resource "google_storage_bucket" "bkt_p_bootstrap_notebooks" {
  name               = "${var.project_bootstrap}-bkt-0000-p-bootstrap-notebooks"
  project            = var.project_bootstrap
  location           = var.region
  uniform_bucket_level_access = true
  force_destroy      = true

  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = var.key_confid_data
  }
  depends_on = [google_kms_crypto_key_iam_binding.iam_p_gcs_sa_confid_etl]
}

// a temporary bucket for intake for data flow/DLP processing
resource "google_storage_bucket" "bkt_p_data_etl" {
  name               = "${var.project_bootstrap}-bkt-0000-p-data-etl"
  project            = var.project_trusted_data_etl
  location           = var.region
  uniform_bucket_level_access = true
  force_destroy      = true


  encryption {
    default_kms_key_name = var.key_confid_etl
  }
  // create a bucket lifecycle policy to delete after 1 day
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = "1"
    }
  }
  depends_on = [google_kms_crypto_key_iam_binding.iam_p_gcs_sa_confid_etl]
}

resource "google_storage_bucket_object" "confid_data" {
  name     = "confid_data.csv"
  source   = "${path.module}/files/confid.csv"
  bucket   = google_storage_bucket.bkt_p_data_etl.name
} 
