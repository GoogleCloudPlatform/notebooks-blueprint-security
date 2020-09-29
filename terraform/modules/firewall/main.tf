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

// https://www.terraform.io/docs/providers/google/r/compute_firewall.html
// Need a firewall rule so that the bastion host is accessible, a smaller range (/32?) would be better,
// but for now, this will suffice.

#TODO expose corp network (or data scientist IP)
# only allow SSH to the notebooks
# resource "google_compute_firewall" "scientists-fw" {
#   name          = "gke-demo-bastion-fw"
#   network       = var.vpc_name
#   direction     = "INGRESS"
#   project       = var.project
#   source_ranges = ["104.14.156.165/32"]

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   target_service_accounts = [
#     ${google_service_account.notebook-compute-sa.email}
#   ]
# }

# TODO check port 80 is enough for
# https://cloud.google.com/iap/docs/tutorial-gce#configure_your_firewall
resource "google_compute_firewall" "iap_fw" {
  name          = "fw-iap-trusted-notebooks"
  network       = var.vpc_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
  }
}
