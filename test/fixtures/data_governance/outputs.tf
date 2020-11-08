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

output "project_id" {
  description = "the project for kms"
  value       = var.project_trusted_kms
}

output "region" {
  description = "The region in which to create the data resources"
  value       = var.region
}

output "key_ring_name" {
  description = "name of the KMS key ring"
  value       = module.data_governance.key_ring_name
}

output "etl_key_name" {
  description = "name of the KMS key used on the ETL bucket"
  value       = basename(module.data_governance.key_confid_etl)
}

output "data_key_name" {
  description = "name of the KMS key used on the data bucket"
  value       = basename(module.data_governance.key_confid_data)
}

output "secret_id" {
  description = "secret id"
  value       = module.data_governance.secret_id
}
