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

# network_self_link can be used to reference the confid data key created by this module
output "key_confid_data" {
  value = google_kms_crypto_key.key_eeee_p_confid_data.self_link
}

# subnet_self_link can be used to reference the confid etl key created by this module
output "key_confid_etl" {
  value = google_kms_crypto_key.key_eeee_p_confid_etl.self_link
}