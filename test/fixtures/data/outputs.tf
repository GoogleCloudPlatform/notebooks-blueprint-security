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

output "bkt_data_etl" {
  description = "Bucket URI for data ETL"
  value       = module.data.bkt_p_data_etl
}

output "bkt_data_etl_name" {
  description = "name of the ETL bucket"
  value = basename(module.data.bkt_p_data_etl)
}

output "bkt_data_name" {
  description = "name of the ETL bucket"
  value = module.data.bkt_p_data.name
}

output "bkt_notebooks_name" {
  description = "name of the notebooks bucket"
  value = module.data.bkt_p_bootstrap_notebook.name
}

output "bkt_region" {
  description = "region of the bucket"
  value = var.region
}

output "bkt_data_etl_key_name" {
  description = "name of the KMS key used on the ETL bucket"
  value = module.data_governance.key_confid_etl
}

output "bkt_data_key_name" {
  description = "name of the KMS key used on the data bucket"
  value = module.data_governance.key_confid_data
}

output "bkt_notebooks_key_name" {
  description = "name of the KMS key used on the notebooks bucket"
  value = module.data_governance.key_confid_data
}

output "bkt_data_project_name" {
  description = "project name where the data bucket exists"
  value = module.data.bkt_p_data.project
}

output "bkt_data_etl_project_id" {
    description = "project name where the data ETL bucket exists"
    value = module.data.bkt_p_data_etl_obj.project
}

output "bkt_notebooks_project_id" {
    description = "project name where notebook bucket exists"
    value = module.data.bkt_p_bootstrap_notebook.project
}

output "bq_dataset_dataset_id" {
  description = "sample dataset id"
  value = module.data.bq_p_dataset_obj.dataset_id
}

output "bq_dataset_project_id" {
  description = "project id where the sample dataset exists"
  value = module.data.bq_p_dataset_obj.project
}

output "bq_table_id" {
  description = "sample table with PII"
  value = module.data.bq_p_table_obj.table_id
}

output "bq_table_num_rows" {
  description = "total rows in sample table with PII"
  value = var.table_num_rows
}