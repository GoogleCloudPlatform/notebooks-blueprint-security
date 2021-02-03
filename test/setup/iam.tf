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
  int_required_roles_folder = [
    "roles/serviceusage.serviceUsageConsumer",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountUser",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ]

  int_required_roles_project_analytics = [
    "roles/compute.admin",
    "roles/notebooks.runner",
    "roles/cloudkms.admin",
  ]

  int_required_roles_project_data = [
    "roles/iam.roleAdmin",
    "roles/bigquery.jobUser",
    "roles/bigquery.user",
    "roles/bigquery.dataOwner",
  ]

  int_required_roles_project_kms = [
    "roles/cloudkms.admin",
    "roles/storage.objectCreator",
  ]

  int_required_roles_org = [
    "roles/orgpolicy.policyAdmin",
    "roles/accesscontextmanager.policyAdmin",
    "roles/iam.securityAdmin",
    "roles/serviceusage.serviceUsageConsumer",
  ]


}

resource "google_service_account" "int_test" {
  project      = var.project_trusted_analytics
  account_id   = format("ci-account-%s", random_string.random_name.result)
  display_name = format("ci-account-%s", random_string.random_name.result)
}

resource "google_organization_iam_member" "int_test_org" {
  count = length(local.int_required_roles_org)

  org_id = var.org_id
  role   = local.int_required_roles_org[count.index]
  member = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_folder_iam_member" "int_test" {
  count = length(local.int_required_roles_folder)

  folder = local.folder_trusted
  role   = local.int_required_roles_folder[count.index]
  member = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_project_iam_member" "int_test_analytics" {
  count = length(local.int_required_roles_project_analytics)

  project = var.project_trusted_analytics
  role    = local.int_required_roles_project_analytics[count.index]
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_project_iam_member" "int_test_data" {
  count = length(local.int_required_roles_project_data)

  project = var.project_trusted_data
  role    = local.int_required_roles_project_data[count.index]
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_project_iam_member" "int_test_kms" {
  count = length(local.int_required_roles_project_kms)

  project = var.project_trusted_kms
  role    = local.int_required_roles_project_kms[count.index]
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_test.id
}
