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

resource "random_string" "random_vpc" {
  length    = 4
  min_lower = 4
  special   = false
}

// This file creates a custom VPC network and subnet to contain the notebooks
// A network to hold trusted notebooks.
resource "google_compute_network" "vpc_trusted_private" {
  name                    = format("vpc-%s-%s", var.trusted_vpc_name, random_string.random_vpc.result)
  project                 = var.project_id
  auto_create_subnetworks = false
}

// Subnetwork for the notebooks
resource "google_compute_subnetwork" "subnet_trusted_private" {
  name                     = format("sbn-%s-%s-%s", var.trusted_subnet_name, var.region, random_string.random_vpc.result)
  project                  = var.project_id
  ip_cidr_range            = var.ip_range
  network                  = google_compute_network.vpc_trusted_private.self_link
  region                   = var.region
  private_ip_google_access = true
}

#TODO add NAT and separate subnet for nat access.  there is a set of notebook that cannot use NAT.
