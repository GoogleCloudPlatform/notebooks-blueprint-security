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

variable "org" {
  description = "The region in which to create the network."
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