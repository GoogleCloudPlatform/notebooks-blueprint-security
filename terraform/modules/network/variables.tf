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

variable "trusted_vpc_name" {
  description = "higher trust VPC name"
  type        = string
  default     = "higher-trust-private"
}

variable "trusted_subnet_name" {
  description = "higher trust VPC name"
  type        = string
  default     = "higher-trust-private"
}

variable "project_id" {
  description = "the project for this network"
  type        = string
}

variable "ip_range" {
  description = "Specifies the CIDR for the network's primary subnetwork"
  type        = string
  default     = "10.100.32.0/21"
}

variable "region" {
  description = "The region of the network"
  type        = string
}