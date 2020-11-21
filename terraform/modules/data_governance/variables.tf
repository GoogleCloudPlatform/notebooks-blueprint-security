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

variable "keyring_name" {
  description = "the keyring name that holds keys protecting trusted data"
  type        = string
  default     = "trusted_keys"
}


variable "trusted_data_key_name" {
  description = "name of the key that protects trusted data"
  type        = string
  default     = "trusted_data"
}

variable "trusted_data_etl_key_name" {
  description = "name of the key that protects trusted data ETL"
  type        = string
  default     = "trusted_data_etl"
}

variable "sample_secret_name" {
  description = "name of the sample secret"
  type        = string
  default     = "trusted_sample"
}

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
  description = "The number of seconds to rotate the key used to protect data (i.e 45 days)"
  type        = string
  default     = "3888000s"
}

variable "etl_key_rotation_seconds" {
  description = "The number of seconds to rotate the key used to protect data etl (i.e 10 days)"
  type        = string
  default     = "864000s"
}
