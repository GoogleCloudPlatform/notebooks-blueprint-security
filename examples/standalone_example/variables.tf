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

variable "vpc_perimeter_ip_subnetworks" {
  description = "IP subnets for perimeters."
  type        = list(string)
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
  description = "The trusted project for data used by notebooks."
  type        = string
}

variable "project_trusted_kms" {
  description = "Top trusted project for encryption keys."
  type        = string
}

variable "trusted_private_network" {
  description = "Network for Notebooks.  Should be a restricted private VPC."
  type        = string
}

variable "trusted_private_subnet" {
  description = "Subnet with no external IP for Notebooks.  Should be part of a restricted private network."
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

variable "dataset_id" {
  description = "The BigQuery data for notebooks."
  type        = string

}

variable "zone" {
  description = "The zone in which to create the secured notebook. Must match the region."
  type        = string
}
