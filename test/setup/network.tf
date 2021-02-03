/**
 * Copyright 2021 Google LLC
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

locals {
  subnet_name   = "example-subnet-01"
  subnet_region = "us-central1"
}
module "example_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_trusted_analytics
  network_name = format("example-vpc-%s", random_string.random_name.result)
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = var.vpc_subnet_range
      subnet_region         = local.subnet_region
      subnet_private_access = "true"
      description           = "example subnet for integration tests"
    },
  ]

  depends_on = [module.project_services_analytics]
}
