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

locals {
  bootstrap_bkt_name = format("restricted-bootstrap-nbk-%s", random_string.random_name.result)
  data_key_name      = format("sample_data_key_name_%s", random_string.random_name.result)
  sample_csv_name    = "CCRecords_1564602825.csv"
  dataset_name       = format("notebook_sample_pii_%s", random_string.random_name.result)
  pii_table_id       = "sample_tbl"
}

module "bq_data_key" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = var.project_trusted_kms
  location             = local.region
  keyring              = format("trusted-bq-keyring-%s", random_string.random_name.result)
  keys                 = [local.data_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = "3888000s" # 45 days

  depends_on = [module.project_services_kms]
}

#=====================================================================
# Grant access to KMS to support CMEK for data services
# This is fine grain limited to only the single key.
#
#=====================================================================
data "google_bigquery_default_service_account" "bq_default_account" {
  project = var.project_trusted_data
}

data "google_storage_project_service_account" "gcs_default_account_data" {
  project = var.project_trusted_data
}

# get the GCS default service account for the project holding bootstrap code
data "google_storage_project_service_account" "gcs_default_account_bootstrap" {
  project = var.project_trusted_kms
}

resource "google_kms_crypto_key_iam_binding" "iam_p_bq_sa_confid" {
  crypto_key_id = module.bq_data_key.keys[local.data_key_name]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${data.google_bigquery_default_service_account.bq_default_account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_data.email_address}",
    "serviceAccount:${data.google_storage_project_service_account.gcs_default_account_bootstrap.email_address}",

  ]
}

module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.0"

  dataset_id                 = local.dataset_name
  dataset_name               = local.dataset_name
  description                = "Dataset holds tables with PII"
  project_id                 = var.project_trusted_data
  location                   = local.region
  encryption_key             = module.bq_data_key.keys[local.data_key_name]
  delete_contents_on_destroy = true
  tables = [
    {
      table_id          = "${local.pii_table_id}",
      schema            = "./empty_schema.json",
      clustering        = [],
      expiration_time   = null,
      time_partitioning = null,
      labels = {
        env = "prod"
      },
    }
  ]

  depends_on = [
    google_kms_crypto_key_iam_binding.iam_p_bq_sa_confid,
    module.project_services_data,
    module.project_services_analytics
  ]
}

resource "random_string" "tmp_name" {
  length    = 4
  min_lower = 4
  special   = false
}

# Sample data is created from a public compressed csv file.  To unload it into BQ, the happens:
# 1. create a tmp bucket
# 2. unzip the sample csv file and upload it as an object into the tmp bucket
# 3. use BQ job load to import the csv file from the bucket into a BQ table.
module "tmp_data" {
  source        = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  project_id    = var.project_trusted_data
  name          = format("tmp_sample_data_%s", random_string.tmp_name.result)
  location      = local.region
  force_destroy = true
  encryption = {
    default_kms_key_name = module.bq_data_key.keys[local.data_key_name]
  }
}

resource "null_resource" "download_sample_cc_into_gcs" {
  provisioner "local-exec" {
    command = <<EOF
    curl -X GET -o "sample_data_scripts.tar.gz" "http://storage.googleapis.com/dataflow-dlp-solution-sample-data/sample_data_scripts.tar.gz"
    tar -zxvf sample_data_scripts.tar.gz
    rm sample_data_scripts.tar.gz
    tmpfile=$(mktemp)
    echo ${google_service_account_key.int_test.private_key} | base64 --decode > $tmpfile
    gcloud auth activate-service-account --key-file=$tmpfile
    gsutil cp solution-test/${local.sample_csv_name}  ${module.tmp_data.bucket.url}
    rm -fr solution-test/
    EOF
  }
}

resource "google_bigquery_job" "table_load" {
  job_id  = format("sample_table_load_%s", formatdate("YYYYMMMDD_hhmmss", timestamp()))
  project = var.project_trusted_data

  load {
    source_uris = [
      "${module.tmp_data.bucket.url}/${local.sample_csv_name}",
    ]

    destination_table {
      project_id = var.project_trusted_data
      dataset_id = module.bigquery.bigquery_dataset.dataset_id
      table_id   = "${local.pii_table_id}"
    }

    skip_leading_rows     = 1
    schema_update_options = ["ALLOW_FIELD_RELAXATION", "ALLOW_FIELD_ADDITION"]

    write_disposition = "WRITE_APPEND"
    autodetect        = true
  }

  depends_on = [
    module.bigquery,
    null_resource.download_sample_cc_into_gcs,
  ]
}
