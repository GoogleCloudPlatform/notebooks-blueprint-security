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

# bucket names must be all lowercase
resource "random_string" "random_bootstrap" {
  length    = 4
  min_lower = 4
  special   = false
}

locals {
  bootstrap_bkt_name = format("restricted-%s-%s", var.bootstrap_notebooks_bucket_name, random_string.random_bootstrap.result)
}

module "bootstrap" {
  source        = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  project_id    = var.project_bootstrap
  name          = local.bootstrap_bkt_name
  location      = var.region
  force_destroy = true
  encryption    = {
    default_kms_key_name = var.data_key
  } 
}
