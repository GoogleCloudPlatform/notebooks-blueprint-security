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

variable "access_level_name" {
  description = "Access level name"
  type        = string
  default     = "higher_trust_analytic"
}

variable "service_perimeter_name" {
  description = "service perimeter name"
  type        = string
  default     = "higher_trust_analytics"
}

variable "org" {
  description = "The org ID for resource structure creation"
  type        = string
}

variable "policy_name" {
  description = "The name of the policy to use for perimeters."
  type        = string
}

variable "region" {
  description = "The region in which to create the network."
  type        = string
}

variable "resources" {
  description = "List of project resources to apply perimeter to."
  type        = list(string)
}

variable "ip_subnetworks" {
  description = "Networks allowed by perimeters."
  type        = list(string)
}

variable "terraform_sa_email" {
  description = "String for the email of the Terraform Service Account"
  type        = string
}

variable "restricted_services" {
  description = "List of restricted services included in the perimeter"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "notebooks.googleapis.com",
    "bigquery.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}
