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

variable "dataset_name" {
  description = "dataset name holding trusted data"
  type        = string
  default     = "sample_pii_data"
}

variable "bootstrap_notebooks_bucket_name" {
  description = "bucket name holding bootstrap scripts for notebooks"
  type        = string
  default     = "notebook_bootstrap"
}

variable "project_trusted_data" {
  description = "the project holding data used by notebooks"
  type        = string
}

variable "project_trusted_analytics" {
  description = "the project holding analytics notebooks"
  type        = string
}

variable "project_bootstrap" {
  description = "the project holding bootstrap items"
  type        = string
}

variable "region" {
  description = "The region in which to create the data resources"
  type        = string
}

variable "data_key" {
  description = "KMS/HSM key protecting pii data"
  type        = string
}

variable "google_managed_members" {
  description = "List of members for KMS key"
  default     = []
}

variable "confid_users" {
  description = "The list of groups with privileged users that can access PII data."
  default     = []
}

variable "pii_table_id" {
  description = "Table that contains PII data used by data scientists"
  type        = string
  default     = "sample_pii_table"
}
