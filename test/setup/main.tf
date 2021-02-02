/**
 * Copyright 2019 Google LLC
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


# append all resource names to help with testing
# buckets must be all lowercase for buckets
resource "random_string" "random_name" {
  length    = 4
  min_lower = 4
  special   = false
}

locals {
  zone   = "us-central1-a"
  region = split("-", local.zone)[0]

  folder_trusted = "folders/${data.google_project.trusted_analytics.folder_id}"
}

# module "project_analytics" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 10.1.0"

#   name              = "notebooks-analytics"
#   random_project_id = "true"
#   org_id            = var.org_id
#   folder_id         = var.folder_id
#   billing_account   = var.billing_account
#   #impersonate_service_account  = "blueprint-terraform-i@elo-sandbox.iam.gserviceaccount.com"
#   #skip_gcloud_download = true

#   activate_apis = [
#     "compute.googleapis.com",
#     "accesscontextmanager.googleapis.com",
#     "bigquery.googleapis.com",
#     "cloudkms.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "iam.googleapis.com",
#     "notebooks.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "storage-api.googleapis.com",
#     "iamcredentials.googleapis.com",
#     "serviceusage.googleapis.com",
#   ]
# }

# module "project_data" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 10.0"

#   name              = "notebooks-data"
#   random_project_id = "true"
#   org_id            = var.org_id
#   folder_id         = var.folder_id
#   billing_account   = var.billing_account
#   skip_gcloud_download = true

#   activate_apis = [
#     "bigquery.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "storage-api.googleapis.com",
#     "serviceusage.googleapis.com"
#   ]
# }

# module "project_kms" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 10.0"

#   name              = "notebooks-kms"
#   random_project_id = "true"
#   org_id            = var.org_id
#   folder_id         = var.folder_id
#   billing_account   = var.billing_account
#   skip_gcloud_download = true

#   activate_apis = [
#     "cloudkms.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "storage-api.googleapis.com",
#     "serviceusage.googleapis.com",
#   ]
# }

data "google_project" "trusted_analytics" {
  project_id = var.project_trusted_analytics
}
