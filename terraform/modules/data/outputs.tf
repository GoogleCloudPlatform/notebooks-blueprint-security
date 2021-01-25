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

# externalized for notebook module and testing
output "bkt_p_bootstrap_notebook" {
  description = "bucket containing the boot scripts for notebooks"
  value       = module.bootstrap.bucket
}

# externalized for testing
output "bq_p_dataset_obj" {
  description = "object reference for bigquery dataset"
  value       = module.bigquery.bigquery_dataset
}

# externalized for testing
output "bq_p_table_obj" {
  description = "object reference for bigquery table"
  value       = module.bigquery.bigquery_tables
}
