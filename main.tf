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

# append all resource names to help with testing
# buckets must be all lowercase for buckets
resource "random_string" "random_name" {
  length    = 4
  min_lower = 4
  special   = false
}

locals {
  region             = split("-", var.zone)[0]
  folder_trusted     = "folders/${data.google_project.trusted_analytics.folder_id}"
  bootstrap_bkt_name = format("restricted-%s-%s", var.bootstrap_notebooks_bucket_name, random_string.random_name.result)
}

# The key ring holds data keys that encrypt any PII data at rest such as BQ, GCS, or boot images
# Initial key is HSM backed key rotates every 45 days
module "kms_data" {
  source               = "terraform-google-modules/kms/google"
  project_id           = var.project_trusted_kms
  location             = local.region
  keyring              = format("trusted-data-keyring-%s", random_string.random_name.result)
  keys                 = [var.notebook_key_name]
  key_protection_level = "HSM"
  key_rotation_period  = "3888000s" # 45 days
}

module "bootstrap" {
  source        = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  project_id    = var.project_trusted_kms
  name          = local.bootstrap_bkt_name
  location      = local.region
  force_destroy = true
  encryption = {
    default_kms_key_name = module.kms_data.keys[var.notebook_key_name]
  }
}

# IAM for the CAIP service account to read the post startup script.
resource "google_storage_bucket_iam_member" "member" {
  bucket = module.bootstrap.bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
}

resource "google_storage_bucket_object" "postscript" {
  name   = "post_startup_script.sh"
  source = "${path.module}/bootstrap_files/post_startup_script.sh"
  bucket = module.bootstrap.bucket.name
}

# IAM policy for each Data Scientist
resource "google_project_iam_member" "notebook_caip_user_iam" {
  project  = var.project_trusted_analytics
  role     = "roles/notebooks.viewer"
  for_each = toset(var.caip_users)

  member = "user:${each.value}"
}

# Creates a trusted notebook per relevant user that has file
# download disabled. Although some values are hardcoded, you can
# customize them using variables.
resource "google_notebooks_instance" "caip_nbk_p_trusted" {
  provider        = google-beta
  project         = var.project_trusted_analytics
  for_each        = toset(var.caip_users)
  service_account = google_service_account.sa_p_notebook_compute.email

  name         = format("caip-nbk-%s-%s-%s", var.notebook_name_prefix, split("@", each.value)[0], random_string.random_name.result)
  location     = var.zone
  machine_type = "n1-standard-1"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  instance_owners = [each.value]

  post_startup_script = format("%s/%s", module.bootstrap.bucket.url, google_storage_bucket_object.postscript.name)

  install_gpu_driver = false
  boot_disk_type     = "PD_SSD"
  boot_disk_size_gb  = 110

  disk_encryption = "CMEK"
  kms_key         = module.kms_data.keys[var.notebook_key_name]

  # only allow network with private IP
  no_public_ip = true

  # If true, forces to use an SSH tunnel.
  no_proxy_access = false

  network = var.trusted_private_network
  subnet  = var.trusted_private_subnet

  labels = {
    blueprint = "security"
  }

  metadata = {
    terraform                  = "true"
    proxy-mode                 = "mail"
    proxy-user-mail            = each.value
    notebook-disable-root      = "true"
    notebook-disable-downloads = "true"
    notebook-disable-nbconvert = "true"
    serial-port-enable         = "FALSE"
    block-project-ssh-keys     = "TRUE"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      # Ignore changes to the following attributes to allow idempotent re-deployment
      # when re-applying, terraform cannot get the disk-encryption type even though it's already set to CMEK
      create_time,
      disk_encryption,
      kms_key,
      update_time,
      vm_image,
    ]
  }

  depends_on = [
    module.kms_data,
    module.iam_grant_policy,
    google_storage_bucket_object.postscript,
    google_service_account.sa_p_notebook_compute,
    google_compute_subnetwork_iam_binding.subnet_binding,
  ]
}

module "access_level_members_higher_trust" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  policy         = var.default_policy_id
  name           = format("higher_trust_notebooks_members_%s", random_string.random_name.result)
  members        = var.trusted_scientists
  ip_subnetworks = var.vpc_perimeter_ip_subnetworks

  # Note: Below are additional policy attributes you should configure based on your security policies, which are additional context information part of endpoint verification configuration.
  # regions                     = var.vpc_perimeter_regions
  # allowed_encryption_statuses = ["ENCRYPTED"]
  # require_corp_owned          = true
  # require_screen_lock         = true
}

data "google_project" "trusted_data" {
  project_id = var.project_trusted_data
}

data "google_project" "trusted_analytics" {
  project_id = var.project_trusted_analytics
}

data "google_project" "trusted_kms" {
  project_id = var.project_trusted_kms
}

module "regular_service_perimeter_higher_trust" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  policy         = var.default_policy_id
  perimeter_name = format("higher_trust_notebooks_%s", random_string.random_name.result)
  description    = "Perimeter shielding Notebook projects with PII data"
  resources = [
# TODO add in
    # "${data.google_project.trusted_data.number}",
    # "${data.google_project.trusted_analytics.number}",
    # "${data.google_project.trusted_kms.number}",
  ]
  access_levels = [module.access_level_members_higher_trust.name]
  restricted_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "notebooks.googleapis.com",
    "bigquery.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]

  depends_on = [
    google_notebooks_instance.caip_nbk_p_trusted,
  ]
}
