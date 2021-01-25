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

module "network" {
  source     = "../../../terraform/modules/network"
  project_id = var.project_networks
  region     = var.region_trusted_network
}

module "data_governance" {
  source          = "../../../terraform/modules/data_governance"
  project_kms     = var.project_trusted_kms
  project_secrets = var.project_trusted_kms
  region          = var.region
}

# data module depends on the data_governance module to create the KMS key used for CMEK
# on the buckets and BQ
module "data" {
  source                    = "../../../terraform/modules/data"
  project_trusted_data      = var.project_trusted_data
  project_trusted_data_etl  = var.project_trusted_data_etl
  project_bootstrap         = var.project_trusted_kms
  project_trusted_analytics = var.project_trusted_analytics
  region                    = var.region
  key_confid_data           = module.data_governance.key_confid_data
  key_confid_etl            = module.data_governance.key_confid_etl
  confid_users              = var.confid_users
  google_managed_members = [
    "serviceAccount:${var.terraform_sa_email}"
  ]
  restricted_viewer_role    = var.restricted_viewer_role
  depends_on = [
    module.data_governance,
  ]
}

# data module depends on the data_governance module to create the KMS key used for CMEK
# on the buckets and BQ
module "notebooks" {
  source              = "../../../terraform/modules/notebooks"
  project_id          = var.project_trusted_analytics
  zone                = var.zone
  caip_users          = var.caip_users
  caip_sa_email       = var.caip_compute_sa_email
  bucket_bootstrap    = module.data.bkt_p_bootstrap_notebook
  vpc_trusted_private = module.network.vpc_trusted_private
  sb_trusted_private  = module.network.subnet_trusted_private
  key_confid_data     = module.data_governance.key_confid_data
  depends_on = [
    module.network,
    module.data_governance,
    module.data
  ]
}
