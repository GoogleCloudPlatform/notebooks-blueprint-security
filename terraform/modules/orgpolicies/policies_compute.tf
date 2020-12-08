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
# These are the policies defined
# - Disable all public IP:  constraint/compute.vmExternalIpAccess
# - No default network: constraints/compute.skipDefaultNetworkCreation
# - No Serial Port access: constraints/compute.disableSerialPortAccess
# - No serial port logging: constraints/compute.disableSerialPortLogging
# - Require OS login: constraints/compute.requireOsLogin
# 
# (Optional policies)
# - Require shielded VM: constraints/compute.requireShieldedVm
# - Restrict Shared VPC Subnets: constraints/compute.restrictSharedVpcSubnetworks
# none

resource "google_folder_organization_policy" "external_ip_policy" {
  folder     = var.folder_trusted
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}

resource "google_folder_organization_policy" "network_policy" {
  folder     = var.folder_trusted
  constraint = "compute.skipDefaultNetworkCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_folder_organization_policy" "serial_port_access_policy" {
  folder     = var.folder_trusted
  constraint = "compute.disableSerialPortAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_folder_organization_policy" "serial_port_logging_policy" {
  folder     = var.folder_trusted
  constraint = "compute.disableSerialPortLogging"

  boolean_policy {
    enforced = true
  }
}

resource "google_folder_organization_policy" "ssh_policy" {
  folder     = var.folder_trusted
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}

resource "google_folder_organization_policy" "protocol_forwarding_creation" {
  folder     = var.folder_trusted
  constraint = "compute.restrictProtocolForwardingCreationForTypes"

  list_policy {
    allow {
      values = ["is:INTERNAL"]
    }
  }
}

resource "google_folder_organization_policy" "vpc_subnet_policy" {
  folder     = var.folder_trusted
  constraint = "compute.restrictSharedVpcSubnetworks"

  list_policy {
    allow {
      values = var.vpc_subnets_projects_allowed
    }
  }
}

# Optional
# TODO CAIP APIs do not allow create VM with shielded_policy, so cannot enable.
# For now, need to have a script that runs later to stop the VM and enable the policy
# resource "google_folder_organization_policy" "shielded_policy" {
#   folder     = var.folder_trusted
#   constraint = "compute.requireShieldedVm"
#   boolean_policy {
#     enforced = true
#   }
# }
#
##TODO expose this with neworking
#locals {
#  allowed_vpc_subnets = "under:${google_project.prj_trusted_analytics.id}"
#}
