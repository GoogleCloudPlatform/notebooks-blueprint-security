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

# Organizational Policies (applied at the folder level)
#
# These are the minimum policies
# - No outside domains: constraints/iam.allowedPolicyMemberDomains
# - No default SA: constraints/iam.disableServiceAccountCreation
# - No SA Key creation: constraints/iam.disableServiceAccountKeyCreation
# - No default grants: constraints/iam.automaticIamGrantsForDefaultServiceAccounts
#
# (Optional policies)
# - None

# TODO expose this at the top level
# TODO debug how to only allow the company's domain
#resource "google_folder_organization_policy" "domain_policy" {
#  folder     = google_folder.fldr_trusted.name
#  constraint = "iam.allowedPolicyMemberDomains"
#
#  list_policy {
#    allow {
#      values = ["google.com"]
#    }
#  }
#}

resource "google_folder_organization_policy" "service_account_policy" {
  folder     = google_folder.fldr_trusted.name
  constraint = "iam.disableServiceAccountCreation"

  boolean_policy {
    enforced = true
  }
}

// TODO can the SA be in a separate project to be centrally managed?  For now, place into the Analytics folder
// Override org policy to only allow service accounts in the analytics project
resource "google_project_organization_policy" "service_account_policy" {
  project    = google_project.prj_trusted_analytics.name
  constraint = "iam.disableServiceAccountCreation"

  boolean_policy {
    enforced = false
  }
}

resource "google_folder_organization_policy" "service_account_key_policy" {
  folder     = google_folder.fldr_trusted.name
  constraint = "iam.disableServiceAccountKeyCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_folder_organization_policy" "iam_grant_policy" {
  folder     = google_folder.fldr_trusted.name
  constraint = "iam.automaticIamGrantsForDefaultServiceAccounts"

  boolean_policy {
    enforced = true
  }
}
