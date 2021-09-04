#!/bin/bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Provide your privileged service account used by terraform.
# This will likely be the same one used from the security foundational blueprint
# otherwise, comment it out, so that one can be automatically generated
export TERRAFORM_SA=""  # e.g. <name>@<projectID>.iam.gserviceaccount.com

export ORGANIZATION_ID="" # 12345678

# Existing access policy ID number
# e.g. 99998888
# Note: only provide the numeric identifier from accessPolicies/<policyName>"
# gcloud access-context-manager policies list --organization <orgID> --format json | jq .[].name | sed 's/"//g' | awk '{split($0,a,"/"); print a[2]}'
export POLICY_NAME=""

# Provide your billing account
# gcloud beta billing accounts list
# ABCDEF-123456-A1B2C3
export BILLING_ACCOUNT=""

export TRUSTED_FOLDER_ID="" # 12345678

# folder that has all the trusted projects (e.g folder/123456890)
export TRUSTED_FOLDER_RESOURCE_NAME="organizations/${ORGANIZATION_ID}/folders/${TRUSTED_FOLDER_ID}"

# Your project names defined in the terraform/terraform.template.tfvars file
# replace <ID> with a real value (e.g. 12345678)
export PRJ_HIGH_TRUST_ANALYTICS="${TRUSTED_FOLDER_RESOURCE_NAME}/projects/<ID>"
export PRJ_HIGH_TRUST_KMS="${TRUSTED_FOLDER_RESOURCE_NAME}/projects/<ID>"
export PRJ_HIGH_TRUST_DATA="${TRUSTED_FOLDER_RESOURCE_NAME}/projects/<ID>"
export PRJ_HIGH_TRUST_DATA_ETL="${TRUSTED_FOLDER_RESOURCE_NAME}/projects/<ID>"
export ZONE="" # e.g. us-central1-a
export REGIONS="" # e.g us;  these should be separate by spaces such as "us eu"
export DOMAIN=""  # your organization's domain

# a list of regex's of instances to test
export VM_INSTANCES="//compute.googleapis.com/projects/${PRJ_HIGH_TRUST_ANALYTICS}/.*"

# list of networks where trusted environment can use.  values are separated by spaces (e.g. <...>/network1 <...>/network2)
# e.g https://www.googleapis.com/compute/v1/projects/<projectid>/global/networks/<networkName>
export NETWORKS=""

# list of access level policy names.  values are separated by a space.
export VPC_SC_ACCESS_LEVELS_NAME=""

# list of projects within the vpc-sc.  values are separated by a space.
# e.g.  projects/11111111 projects/2222222 projects/333333
export VPC_SC_PROJECTS=""

#===============================================================
# Output for visual inspection
#===============================================================
echo ""
echo "Environment setup with values:"
echo "==================================================="
echo "Terraform service account: ${TERRAFORM_SA:?}"
echo "Organization: ${ORGANIZATION_ID:?}"
echo "Billing account: ${BILLING_ACCOUNT:?}"
echo "Policy name: ${POLICY_NAME:?}"
echo "Trusted folder ID: ${TRUSTED_FOLDER_ID:?}"
echo "Deployment project ID: ${TRUSTED_FOLDER_RESOURCE_NAME:?}"
echo "Project high trust analytics: ${PRJ_HIGH_TRUST_ANALYTICS:?}"
echo "Project high trust data: ${PRJ_HIGH_TRUST_DATA:?}"
echo "Project high trust data ETL: ${PRJ_HIGH_TRUST_DATA_ETL:?}"
echo "Project high trust kms: ${PRJ_HIGH_TRUST_KMS:?}"
echo "Zone: ${ZONE:?}"
echo "Regions: ${REGIONS:?}"
echo "Domain: ${DOMAIN:?}"
echo "VM instances: ${VM_INSTANCES:?}"
echo "Networks: ${NETWORKS:?}"
echo "VPC-SC access levels: ${VPC_SC_ACCESS_LEVELS_NAME:?}"
echo "VPC-SC projects: ${VPC_SC_PROJECTS:?}"
echo "==================================================="
echo ""
echo "Please verify these environment variables are correct for your GCP Resources"
echo ""

echo "Creating Kptfile..."
kpt cfg create-setter constraint/ project_owners --type array --field spec.match.members

kpt cfg create-setter constraint/ target_fldr_trusted --type array --field spec.match.target
kpt cfg create-setter constraint/ target_prj_analytics --type array --field spec.match.target
kpt cfg create-setter constraint/ target_prj_kms --type array --field spec.match.target
kpt cfg create-setter constraint/ target_prj_data --type array --field spec.match.target
kpt cfg create-setter constraint/ target_prj_data_etl --type array --field spec.match.target

kpt cfg create-setter constraint/ notebook_zones --type array --field spec.parameters.zones
kpt cfg create-setter constraint/ locations --type array --field spec.parameters.locations

kpt cfg create-setter constraint/ domain ${DOMAIN}

kpt cfg create-setter constraint/ vm_instances --type array --field spec.parameters.instances
kpt cfg create-setter constraint/ allowed_networks --type array --field spec.parameters.allowed

kpt cfg create-setter constraint/ vpc_sc_regions --type array --field spec.parameters.regions
kpt cfg create-setter constraint/ vpc_sc_access_levels --type array --field spec.parameters.required_access_levels
kpt cfg create-setter constraint/ vpc_sc_project_ids --type array --field spec.parameters.required_projects

echo "...configuring setters and updated yaml files"
kpt cfg set constraint/ project_owners ${TERRAFORM_SA}

kpt cfg set constraint/ target_fldr_trusted ${TRUSTED_FOLDER_RESOURCE_NAME}
kpt cfg set constraint/ target_prj_analytics ${PRJ_HIGH_TRUST_ANALYTICS}
kpt cfg set constraint/ target_prj_kms ${PRJ_HIGH_TRUST_KMS}
kpt cfg set constraint/ target_prj_data ${PRJ_HIGH_TRUST_DATA}
kpt cfg set constraint/ target_prj_data_etl ${PRJ_HIGH_TRUST_DATA_ETL}

kpt cfg set constraint/ notebook_zones ${ZONE}
kpt cfg set constraint/ locations ${REGIONS}

kpt cfg set constraint/ domain ${DOMAIN}

kpt cfg set constraint/ vm_instances "${VM_INSTANCES}"
kpt cfg set constraint/ allowed_networks ${NETWORKS}

kpt cfg set constraint/ vpc_sc_regions ${REGIONS}
kpt cfg set constraint/ vpc_sc_access_levels ${VPC_SC_ACCESS_LEVELS_NAME}
kpt cfg set constraint/ vpc_sc_project_ids ${VPC_SC_PROJECTS}

pushd ../../terraform || exit
# source setup_variables.sh
# impersonate with a token (use cloud identity to set the default time to 1 hr)
# this uses Oauth2 so that a SA key isn't needed
gcloud config set auth/impersonate_service_account ${TERRAFORM_SA}
GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)
export GOOGLE_OAUTH_ACCESS_TOKEN

terraform init
terraform plan \
  -out tfplan.tfplan \
  -var-file="terraform.template.tfvars" \
  -var "org=organizations/${ORGANIZATION_ID}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${TERRAFORM_SA}" \
  -var "billing_account=${BILLING_ACCOUNT}"

popd || exit

echo "validator skipped until v0.13 is supported"
# TODO uncomment once validator support terraform v0.13
#terraform-validator-linux-amd64 validate ../../terraform/tfplan.tfplan --policy-path=./tmp

gcloud config unset auth/impersonate_service_account
