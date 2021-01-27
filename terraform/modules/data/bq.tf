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

locals {
  sample_csv_name = "CCRecords_1564602825.csv"
}

resource "random_string" "random_ds" {
  length    = 4
  min_lower = 4
  special   = false
}

module "bigquery" {
  source                     = "terraform-google-modules/bigquery/google"
  dataset_id                 = format("bq_%s_%s", var.dataset_name, random_string.random_ds.result)
  dataset_name               = var.dataset_name
  description                = "Dataset holds tables with PII"
  project_id                 = var.project_trusted_data
  location                   = var.region
  encryption_key             = var.data_key
  delete_contents_on_destroy = true
  tables = [
    {
      table_id          = "${var.pii_table_id}",
      schema            = "empty_schema.json",
      clustering        = [],
      expiration_time   = null,
      time_partitioning = null,
      labels = {
        env = "prod"
      },
    }
  ]
}

# Sample data is created from a public compressed csv file.  To unload it into BQ, the happens:
# 1. create a tmp bucket
# 2. unzip the sample csv file and upload it as an object into the tmp bucket
# 3. use BQ job load to import the csv file from the bucket into a BQ table.
module "tmp_data" {
  source        = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  project_id    = var.project_trusted_data
  name          = format("tmp_sample_data_%s", random_string.random_ds.result)
  location      = var.region
  force_destroy = true
  encryption = {
    default_kms_key_name = var.data_key
  }
}

resource "null_resource" "download_sample_cc_into_gcs" {
  provisioner "local-exec" {
    command = <<EOF
    curl -X GET -o "sample_data_scripts.tar.gz" "http://storage.googleapis.com/dataflow-dlp-solution-sample-data/sample_data_scripts.tar.gz"
    tar -zxvf sample_data_scripts.tar.gz
    rm sample_data_scripts.tar.gz
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
      table_id   = "${var.pii_table_id}"
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
