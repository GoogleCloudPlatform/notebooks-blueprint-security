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
  description = "IP subnets for perimeters"
  type        = list(string)
}

variable "zone" {
  description = "The zone in which to create the secured notebook. Must match the region"
  type        = string
}

variable "resource_locations" {
  description = "The locations used in org policy to limit where resources can be provisioned"
  type        = list(string)
  default     = ["in:us-locations", "in:eu-locations"]
}

variable "org" {
  description = "The org ID for resource structure creation"
  type        = string
}

variable "default_policy_id" {
  description = "The id of the default org policy."
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

variable "parent_env" {
  description = "Top level environment folder that will house the notebook"
  type        = string
}

variable "bootstrap_env" {
  description = "environment folder that has bootstrap resources"
  type        = string
}

variable "project_trusted_kms" {
  description = "Top level trusted environment folder that will house the encryption keys"
  type        = string
}

variable "trusted_private_network" {
  description = "network for Notebooks.  Should be a restricted private VPC."
  type        = string
}

variable "trusted_private_subnet" {
  description = "subnet for Notebooks.  Should be part of a restricted private network"
  type        = string
}

variable "caip_users" {
  description = "The list of users that need an AI Platform Notebook."
}

variable "confid_users" {
  description = "The list of confid users."
}

variable "trusted_scientists" {
  description = "The list of trusted users."
}

variable "billing_account" {
  description = "Billing account required if creating structure. Otherwise, optional"
  type        = string
  default     = ""
}

variable "enable_services_data" {
  description = "The list of services to enable."
  default = [
    "cloudkms.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "enable_services_data_etl" {
  description = "The list of services to enable."
  default = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "enable_services_analytics" {
  description = "The list of services to enable."
  default = [
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "notebooks.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

# likely the same project as the analytics, match the APIs
variable "enable_services_networks" {
  description = "The list of services to enable."
  default = [
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "notebooks.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "enable_services_kms" {
  description = "The list of services to enable."
  default = [
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "terraform_sa_email" {
  description = "String for the email of the Terraform Service Account"
  type        = string
}

variable "data_key_name" {
  description = "Data key used to protect PII data"
  type        = string
  default     = "trusted-data-key"
}

variable "data_etl_key_name" {
  description = "Ephemeral key used to protect data while being transformed"
  type        = string
  default     = "trusted-data-etl-key"
}
