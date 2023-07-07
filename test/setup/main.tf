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

 module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "ci-notebooks-blueprint-security"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

module "analytics_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "notebook-analytics"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "compute.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "notebooks.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

module "data_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "notebook-data"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

module "kms_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "notebook-kms"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}


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

# module "project_services_analytics" {
#   source  = "terraform-google-modules/project-factory/google//modules/project_services"
#   version = "~> 14.2"

#   project_id = var.project_trusted_analytics

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

# module "project_services_data" {
#   source  = "terraform-google-modules/project-factory/google//modules/project_services"
#   version = "~> 14.2"

#   project_id = var.project_trusted_data

#   activate_apis = [
#     "bigquery.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "storage-api.googleapis.com",
#     "serviceusage.googleapis.com"
#   ]
# }

# module "project_services_kms" {
#   source  = "terraform-google-modules/project-factory/google//modules/project_services"
#   version = "~> 14.2"

#   project_id = var.project_trusted_kms

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
