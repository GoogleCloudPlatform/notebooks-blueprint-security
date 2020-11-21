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

variable "parent_env" {
  description = "configured for folder representing a production environment"
  type        = string
}

variable "bootstrap_env" {
  description = "configured for folder representing sensitive bootstrap environment"
  type        = string
}

variable "folder_trusted" {
  description = "Top level folder hosting PII data.  Format should be folder/1234567"
  type        = string
}

variable "project_trusted_analytics" {
  description = "The trusted project for analytics activities and data scientists"
  type        = string
}

variable "project_trusted_data" {
  description = "The trusted project for hosting all PII data"
  type        = string
}

variable "project_trusted_data_etl" {
  description = "The trusted project for ingestion, processing, and de-identification of data"
  type        = string
}

variable "project_trusted_kms" {
  description = "The trusted project in the boot environment that contains encryption keys"
  type        = string
}

variable "billing_account" {
  description = "Billing account required if creating structure. Otherwise, optional"
  type        = string
  default     = ""
}

variable "terraform_sa_email" {
  description = "String for the email of the Terraform Service Account"
  type        = string
}
