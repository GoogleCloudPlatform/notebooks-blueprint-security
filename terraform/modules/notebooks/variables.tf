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

variable "project_id" {
  description = "Project restricted to hold confid notebooks."
}

variable "zone" {
  description = "Zone to host notebook"
}

variable "bucket_bootstrap" {
  description = "Restricted bucket in a bootstrap bucket"
}

variable "vpc_trusted_private" {
  description = "VPC with only private IPs for notebooks"
}

variable "sb_trusted_private" {
  description = "subnet fir private IPs for notebooks"
}

variable "key_confid_data" {
  description = "KMS key used for confid data"
}

variable "caip_sa_email" {
  description = "SA email for notebooks."
}

# Notebook users must have iam permission to use a caip_sa service account
variable "caip_users" {
  description = "The list of users that need an AI Platform Notebook."
  default     = []
}
