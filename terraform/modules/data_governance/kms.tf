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

# TODO add data catalog
# TODO add column level
# TODO add DLP
# TODO add dataflow

// create keyrings based on governance levels
// 1. confid (highest)
//
// each key ring has 2 keys
// 1. data (hardware backed)
// 2. transitory (software backed)

// https://www.terraform.io/docs/providers/google/r/kms_crypto_key.html
// key ring that's regionalized
resource "google_kms_key_ring" "kr_bbbb_p_confid" {
  name     = "kr-bbbb-p-confid"
  location = var.region
  project  = var.project_kms
}

// confid key will encrypt any confid PII data such as BQ, GCS, or boot images
// HSM key rotates every 45 days
resource "google_kms_crypto_key" "key_bbbb_p_confid_data" {
  name            = "key-bbbb-p-confid-data"
  key_ring        = google_kms_key_ring.kr_bbbb_p_confid.self_link
  rotation_period = "3888000s"
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }

  lifecycle {
    prevent_destroy = true
  }
}

// Transitory confid data will be protect by the ETL key
// Software key rotates every 10 days
// Although transitory, have a shorter crypto period due to volume of expected data ETL.
resource "google_kms_crypto_key" "key_bbbb_p_confid_etl" {
  name            = "key-bbbb-p-confid-etl"
  key_ring        = google_kms_key_ring.kr_bbbb_p_confid.self_link
  rotation_period = "864000s"

  lifecycle {
    prevent_destroy = true
  }
}