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

// Determine whether or not the resource structure should be deployed as is or
// use existing hierarchy.
// If you change the value to false, please uncomment the `perimeter_projects` variable below
variable "enable_module_structure" {
  description = "Whether to create the Terraform structure module."
  default     = false
}

# Note: These projects are dynamically created by this blueprint.  If you choose to not deploy the structure module,
# please uncomment and provide the project names in your tfvars file.
variable "perimeter_projects" {
  description = "Projects to add to perimeter."
  type        = list(string)
}

/*
Required Variables
These must be provided at runtime.
*/
variable "zone" {
  description = "The zone in which to create the secured notebook. Must match the region"
  type        = string
}

variable "region" {
  description = "The region 2 letter identifier for keys, storage, vpc-sc, etc."
  type        = string
}

variable "resource_locations" {
  description = "The locations used in org policy to limit where resources can be provisioned"
  type        = list(string)
}

variable "region_trusted_network" {
  description = "The region in which to create the notebook and data (ex: us-central1-a)"
  type        = string
}

variable "default_billing_project_id" {
  description = "The project ID used by the provider.  It specifies the default billing and project to create resource in case one is not specified in terraform"
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

variable "bootstrap_env" {
  description = "environment folder that has bootstrap resources"
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


variable "perimeters_ip_subnetworks" {
  description = "IP subnets for perimeters"
  type        = list(string)
}

variable "terraform_sa_email" {
  description = "String for the email of the Terraform Service Account"
  type        = string
}
