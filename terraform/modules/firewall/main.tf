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

# Allow IAP. Note Access Context Manager policy is an additional layer of endpoint protection that is enabled in this environment.
resource "google_compute_firewall" "iap_fw" {
  name          = "fw-iap-trusted-notebooks"
  network       = var.vpc_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}
