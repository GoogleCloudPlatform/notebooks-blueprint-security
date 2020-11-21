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

# Provide your already created project id that holds terraform service account credentials.
# This project should be in the bootstrap folder's seed project
# ex: prj-aaaa-p-seed
export DEPLOYMENT_PROJECT_ID=""

# Top level folder that will hold all the projects with higher trust data
# ex: fldr-production
export PARENT_FOLDER=""

# Your existing organization ID
# ex: 111112222
# Note: use `glcoud organizations list`
export ORGANIZATION_ID=""

# Existing access policy ID number
# e.g. 99998888
# Note: only provide the numeric identifier from accessPolicies/<policyName>"
# gcloud access-context-manager policies list --organization <orgID> --format json | jq .[].name | sed 's/"//g' | awk '{split($0,a,"/"); print a[2]}'
export POLICY_NAME=""

# Provide your billing account
# gcloud beta billing accounts list
# ABCDEF-123456-A1B2C3
export BILLING_ACCOUNT=""  

# Provide your privileged service account used by terraform.
# This will likely be the same one used from the security foundational blueprint
# otherwise, comment it out, so that one can be automatically generated
# ex: org-terraform@cft-seed-c2e3.iam.gserviceaccount.com
# Note: use the below command to pick the correct terraform, if using the foundational blueprint
# `gcloud iam service-accounts list | grep terraform`
export TERRAFORM_SA=""

#===============================================================
# Output for visual inspection
#===============================================================
echo ""
echo "Environment setup with values:"
echo "==================================================="
echo "Deployment project ID: ${DEPLOYMENT_PROJECT_ID:?}"
echo "Parent Folder: ${PARENT_FOLDER:?}"
echo "Organization: ${ORGANIZATION_ID:?}"
echo "Access Context Policy: ${POLICY_NAME:?}"
echo "Billing Account: ${BILLING_ACCOUNT:?}"
echo "Terraform Service Account: ${TERRAFORM_SA:?}"
echo "==================================================="
echo ""
echo "Please verify these environment variables are correct for your GCP Resources"
echo ""
