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

resource "random_string" "random_sn" {
  length    = 4
  min_lower = 4
  special   = false
}

# handles storing service account key for on-prem applications to call prediction API
resource "google_secret_manager_secret" "sk_c_ml_model_user" {
  secret_id = format("sk-c-ml-model-user-%s", random_string.random_sn.result)
  project   = var.project_secrets
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
      replicas {
        location = "us-west1"
      }
    }
  }
  # TODO add CMEK
}

# TODO determine which secrets group (maybe common?)
# TODO fix group
# TODO fix the role
#resource "google_secret_manager_secret_iam_binding" "binding" {
#  project = google_secret_manager_secret.secret-basic.project
#  secret_id = google_secret_manager_secret.secret-basic.secret_id
#  role = "roles/viewer"
#  members = [
#    "group:ml-prediction-group@example.com",
#  ]
#}