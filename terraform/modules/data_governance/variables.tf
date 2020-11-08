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

variable "project_kms" {
  description = "the project for kms"
  type        = string
}

variable "project_secrets" {
  description = "the project for secrets"
  type        = string
}

variable "region" {
  description = "The region in which to create the network"
  type        = string
}

variable "data_key_rotation_seconds" {
  description = "The number of seconds to rotate the key used to protect data"
  type        = string
  default     = "3888000s"
}

variable "etl_key_rotation_seconds" {
  description = "The number of seconds to rotate the key used to protect data etl"
  type        = string
  default     = "864000s"
}
