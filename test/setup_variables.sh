#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#===============================================================
# The following MUST be set to your project specific 
# resource names and environment
#===============================================================

# Provide your project name that holds terraform service account credentials.
# This project should be in the bootstrap folder's seed project
# This where the terraform state will be
export DEPLOYMENT_PROJECT_ID=""

# Top level trusted folder
# "fldr-trusted"
# "fldr-production"
# " elo-fldr-prod-trusted2"
export PARENT_FOLDER=""

# Your organization ID
# `glcoud organizations list`
export ORGANIZATION_ID=""

# Your project names defined in the terraform/terraform.template.tfvars file
export PRJ_HIGH_TRUST_ANALYTICS=""
export PRJ_HIGH_TRUST_DATA=""
export PRJ_HIGH_TRUST_DATA_ETL=""
export PRJ_HIGH_TRUST_KMS=""

# Provide your privileged service account used by terraform.
# This will likely be the same one used from the security foundational blueprint
# otherwise, comment it out, so that one can be automatically generated
export TERRAFORM_SA=""
export CAIP_COMPUTE_SA=""

# Kitchen-terraform variables
export TF_VAR_organizations=${ORGANIZATION_ID}
export TF_VAR_default_policy_name=${POLICY_NAME}
export TF_VAR_terraform_sa_email=${IMPERSONATION_SA}
export TF_VAR_caip_compute_sa_email=${CAIP_COMPUTE_SA}
export TF_VAR_billing_account=${BILLING_ACCOUNT}
export TF_CLI_ARGS_apply="-var-file=$(pwd)/terraform/terraform.template.tfvars"
export TF_CLI_ARGS_destroy="-var-file=$(pwd)/terraform/terraform.template.tfvars"

#===============================================================
# Output for visual inspection
#===============================================================
echo ""
echo "Environment setup with values:"
echo "==================================================="
echo "Deployment project ID: ${DEPLOYMENT_PROJECT_ID:?}"
echo "Parent Folder: ${PARENT_FOLDER:?}"
echo "Organization: ${ORGANIZATION_ID:?}"
echo "Project high trust analytics: ${PRJ_HIGH_TRUST_ANALYTICS:?}"
echo "Project high trust data: ${PRJ_HIGH_TRUST_DATA:?}"
echo "Project high trust data ETL: ${PRJ_HIGH_TRUST_DATA_ETL:?}"
echo "Project high trust kms: ${PRJ_HIGH_TRUST_KMS:?}"
echo "Terraform Service Account: ${TERRAFORM_SA:?}"
echo "CAIP compute Service Account: ${CAIP_COMPUTE_SA:?}"
echo "==================================================="
echo ""
echo "Please verify these environment variables are correct for your GCP Resources"
echo ""
