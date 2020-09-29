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

/*
This file exposes module variables that can be overridden to customize the network
configuration
https://www.terraform.io/docs/configuration/variables.html
*/

variable "project_trusted_data" {
  description = "the project holding data used by notebooks"
  type        = string
}

variable "project_trusted_data_etl" {
  description = "the project holding temporary data in the ETL pipeline used by data"
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

variable "key_confid_data" {
  description = "The key protecting confid data"
  type        = string
}

variable "key_confid_etl" {
  description = "The key protecting confid data in the ETL pipelie"
  type        = string
}

variable "key_bq_confid_members" {
  description = "List of members for KMS key"
  default = []
}

variable "confid_users" {
  description = "The list of users that confid users."
  default = []
}