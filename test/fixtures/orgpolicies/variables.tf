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

variable "trusted_folder_id" {
  description = "Top level folder hosting PII data.  Format should be folder/1234567"
  type        = string
}

variable "resource_locations" {
  description = "The locations used in org policy to limit where resources can be provisioned"
  type        = list(string)
}

variable "parent_env" {
  description = "The parent env folder for trusted environment"
  type        = string
}

variable "project_trusted_analytics" {
  description = "Project containing VPC subnets used for notebooks"
  type        = string
}
