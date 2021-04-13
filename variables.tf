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

variable "vpc_perimeter_regions" {
  description = "2 letter identifier for regions allowed for VPC access. A valid ISO 3166-1 alpha-2 code."
  type        = list(string)
}

variable "vpc_perimeter_policy_name" {
  description = "Policy name for VPC service control perimeter."
  type        = string
  default     = "higher_trust_perimeter_policy"
}

variable "vpc_perimeter_ip_subnetworks" {
  description = "IP subnets for perimeters."
  type        = list(string)
}

variable "zone" {
  description = "The zone in which to create the secured notebook. Must match the region."
  type        = string
}

variable "resource_locations" {
  description = "The locations used in org policy to limit where resources can be provisioned."
  type        = list(string)
  default     = ["in:us-locations", "in:eu-locations"]
}

variable "default_policy_id" {
  description = "The id of the default org policy."
  type        = string
}

variable "project_trusted_analytics" {
  description = "The trusted project for analytics activities and data scientists."
  type        = string
}

variable "project_trusted_data" {
  description = "The trusted project that has PII data for notebooks."
  type        = string
}

variable "bootstrap_notebooks_bucket_name" {
  description = "Bucket name to create bootstrap scripts for notebooks."
  type        = string
  default     = "notebook_bootstrap"
}

variable "project_trusted_kms" {
  description = "Top level trusted environment folder that will house the encryption keys."
  type        = string
}

variable "trusted_private_network" {
  description = "Network with no external IP for Notebooks.  Should be a restricted private VPC."
  type        = string
}

variable "trusted_private_subnet" {
  description = "Subnet with no external IP for Notebooks.  Should be part of a restricted private network and have logs and private network enabled."
  type        = string
}

variable "confidential_groups" {
  description = "The list of groups allowed to access PII data."
  type        = list(string)
}

variable "trusted_scientists" {
  description = "The list of trusted users."
  type        = list(string)
}

variable "notebook_key_name" {
  description = "HSM key used to protect PII data in Notebooks."
  type        = string
  default     = "trusted-data-key"
}

variable "dataset_id" {
  description = "BigQuery dataset ID with PII data that your scientists need to access from their Notebook."
  type        = string
}

variable "notebook_name_prefix" {
  description = "Prefix for notebooks indicating in higher trusted environment."
  type        = string
  default     = "trusted-sample"
}
