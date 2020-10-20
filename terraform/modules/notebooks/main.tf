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

# IAM for the CAIP service account to read the post startup script.
resource "google_storage_bucket_iam_member" "member" {
  bucket = var.bucket_bootstrap.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${var.caip_sa_email}"
}

resource "google_storage_bucket_object" "postscript" {
  # for_each = fileset("files", "**")
  name     = "post_startup_script.sh"
  source   = "${path.module}/files/post_startup_script.sh"
  bucket   = var.bucket_bootstrap.name
} 

#IAM for each Data Scientist
resource "google_project_iam_member" "notebook_caip_user_iam" {
  project = var.project_id
  role    = "roles/notebooks.viewer"
  for_each        = toset(var.caip_users)

  member  = "user:${each.value}"
}



# Creates a confid notebook per relevant user that has file
# download disabled. Although some values are hardcoded, you can
# customize them using variables.
resource "google_notebooks_instance" "caip_nbk_p_bbbb_confid" {
  provider        = google-beta
  project         = var.project_id
  for_each        = toset(var.caip_users)
  service_account = var.caip_sa_email

  name         = format("caip-nbk-bbbb-confid-%s", replace(each.value, "/[@._]/", "-"))
  location     = var.zone
  machine_type = "n1-standard-1"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  instance_owners = [each.value]

  post_startup_script = format("gs://%s/%s", var.bucket_bootstrap.name, google_storage_bucket_object.postscript.name)

  install_gpu_driver = false
  boot_disk_type     = "PD_SSD"
  boot_disk_size_gb  = 110

  disk_encryption = "CMEK"
  kms_key         = var.key_confid_data

  # only allow network with private IP
  no_public_ip = true

  # If true, forces to use an SSH tunnel.
  no_proxy_access = false

  network = var.vpc_trusted_private
  subnet  = var.sb_trusted_private

  labels = {
    blueprint = "security"
  }

  metadata = {
    terraform                   = "true"
    proxy-mode                  = "mail"
    proxy-user-mail             = each.value
    notebook-disable-root       = "true"
    notebook-disable-downloads  = "true"
    notebook-disable-nbconvert  = "true"
  }

  # TODO update once module no longer in beta
  # allow idempotency
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      # Ignore changes to location since auto corrects to lowercase
      # Ignore changes to access because IAM will update as needed
      # TODO is there a bug when re-applying, where terraform cannot get the disk-encryption type even though it's already set to CMEK?
      create_time,
      disk_encryption,
      kms_key,
      update_time,
      vm_image,
    ]
  }
}




# add secure boot
# TODO how to get the VM name?
#   provisioner "local-exec" {
#     command = "gcloud compute instances stop ${local.notebook_name} && \
#         gcloud compute instances stop ${local.notebook_name} --shielded-secure-boot && \
#         gcloud compute instances start ${local.notebook_name}"
#   }
