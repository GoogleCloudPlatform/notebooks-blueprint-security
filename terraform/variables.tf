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

/*
This file exposes variables that can be overridden to customize your cloud configuration.
https://www.terraform.io/docs/configuration/variables.html
*/

/*
Required Variables
These must be provided at runtime.
*/

variable "zone" {
  description = "The zone in which to create the secured notebook. Must match the region"
  type        = string
}

variable "region" {
  description = "The region in which to create the notebook and data."
  type        = string
}

variable "region_trusted_network" {
  description = "The region in which to create the notebook and data."
  type        = string
}

variable "project" {
  description = "The name of the project in which to create the notebook."
  type        = string
}

variable "org" {
  description = "The org ID for resource structure creation"
  type        = string
}

variable "default_policy_name" {
  description = "The name of the default org policy."
  type        = string
}

variable "folder_trusted" {
  description = "Top level folder hosting PII data.  Format should be folder/1234567"
  type        = string
}

variable "project_trusted_analytics" {
  description = "The trusted project for analytics activies and data scientists"
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

variable "project_trusted_kms" {
  description = "Top level trusted environment folder that will house the encryption keys"
  type        = string
}

variable "project_networks" {
  description = "Contains all networks."
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

variable "enable_module_structure" {
  description = "Whether to create the Terraform structure module."
  default = false
}

variable "billing_account" {
  description = "Billing account required if creating structure. Otherwise, optional"
  type        = string
  default     = ""
}

# TODO(mayran): Add a map project, services.
# Add depends_on in all module
variable "enable_services" {
  description = "The list of services to enable."
  default     = [
    "compute.googleapis.com", 
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "notebooks.googleapis.com",
    "accesscontextmanager.googleapis.com"
  ]
}

variable "perimeters_ip_subnetworks" {
  description = "IP subnets for perimeters"
  type        = list(string)
}

variable "perimeter_projects" {
  description = "Projects to add to perimeter."
  type        = list(string)
}

variable "terraform_sa_email" {
  description = "String for the email of the Terraform Service Account"
  type        = string
}