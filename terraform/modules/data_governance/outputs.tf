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

output "key_confid_data" {
  description = "reference to the key used to protect data"
  value       = google_kms_crypto_key.key_eeee_p_confid_data.self_link
}

output "key_confid_etl" {
  description = "reference to the key used to protect etl pipeline"
  value       = google_kms_crypto_key.key_eeee_p_confid_etl.self_link
}

# externalized for testing
output "key_ring_name" {
  description = "key ring name"
  value       = google_kms_key_ring.kr_eeee_p_confid.name
}

# externalized for testing
output "secret_id" {
  description = "secret id"
  value       = google_secret_manager_secret.sk_c_ml_model_user.secret_id
}
