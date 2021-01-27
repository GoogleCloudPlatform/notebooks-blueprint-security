#!/bin/bash
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

# Example:
# `source setup_variables.sh && ./setup.sh`


DEPLOYMENT_PROJECT=${DEPLOYMENT_PROJECT_ID}  # 12346789
PARENT_FOLDER=${PARENT_FOLDER}               # 11112222
ORGANIZATION=${ORGANIZATION_ID}              # 33334444
POLICY_NAME=${POLICY_NAME}                   # 987654321
BILLING_ACCOUNT=${BILLING_ACCOUNT}           # ABCD-2345-GHIJ
TERRAFORM_SA=${TERRAFORM_SA}                 # If this is set, it's most likely a SA used with the foundational blueprint and is a full email
SA_NAME="notebook-blueprint-terraform-e"


# setup billing project if not deployed through foundational blueprint.
if [[ -z ${TERRAFORM_SA} ]]; then
  echo "Checking if billing project for deployment project is set."

  # only setup project billing, if it doesn't already exist
  RESULT=$(gcloud beta billing projects list --billing-account ${BILLING_ACCOUNT} | grep ${DEPLOYMENT_PROJECT})
  if [[ ${RESULT} == "" ]]; then
    echo "Setting up billing for ${DEPLOYMENT_PROJECT} linked to ${BILLING_ACCOUNT}"
    gcloud projects create ${DEPLOYMENT_PROJECT} \
      --organization ${ORGANIZATION} \
      --billing-project ${DEPLOYMENT_PROJECT}

    gcloud beta billing projects link ${DEPLOYMENT_PROJECT} \
      --billing-account ${BILLING_ACCOUNT}

    gcloud config set billing/quota_project $DEPLOYMENT_PROJECT
  else
    echo "billing is already setup"
  fi
fi

function setup_using_foundation_terraform() {
  # check if SA already exists
  gcloud iam service-accounts list | grep -i ${TERRAFORM_SA}
  if [[ $? -eq 1 ]]; then
    echo "did not find an existing terraform service account.  Please determine if you deployed the security foundation blueprint"
    exit 1
  fi
}

function setup_using_new_terraform() {
  # check if SA already exists
  gcloud iam service-accounts list | grep -i ${SA_NAME}
  if [[ $? -eq 1 ]]; then
    echo "Create the terraform SA to deploy the trusted environment"
    gcloud iam service-accounts create ${SA_NAME} --display-name ${SA_NAME} --project ${DEPLOYMENT_PROJECT}
  fi

  echo "Adding admin policies to the terraform SA...."
  echo ""

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/iam.securityAdmin
  echo "....Added security admin role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/billing.user
  echo "....Added billing user role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/accesscontextmanager.policyAdmin
  echo "....Added access context manager admin role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/resourcemanager.folderCreator
  echo "....Added resource manager folder creator role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
  echo "....Added resource manager project creator role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/orgpolicy.policyAdmin
  echo "....Added org policy admin role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/serviceusage.serviceUsageAdmin
  echo "....Added service usage admin role"

  gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountCreator
  echo "....Added service accout creator role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/editor
  echo "....Added project editor role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/secretmanager.admin
  echo "....Added secrets admin role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/compute.admin
  echo "....Added compute admin role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/iam.securityAdmin
  echo "....Added security admin role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
  echo "....Added service accout user role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/bigquery.jobUser
  echo "....Added service accout job role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/cloudkms.admin
  echo "....Added KMS admin role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/bigquery.user
  echo "....Added BigQuery user role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/storage.admin
  echo "....Added storage admin role"

  gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
  --member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
  --role roles/notebooks.runner
  echo "....Added notebooks runner role"
}

IMPERSONATION_SA=""
if [[ -z ${TERRAFORM_SA} ]]; then
    setup_using_new_terraform
    IMPERSONATION_SA=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com
else
    setup_using_foundation_terraform
    IMPERSONATION_SA=${TERRAFORM_SA}
fi

# impersonate with a token (use cloud identity to set the default time to 1 hr)
# this uses oauth so that a SA key isn't needed
gcloud config set auth/impersonate_service_account ${IMPERSONATION_SA}
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

terraform init

terraform apply \
  -var-file="terraform.tfvars" \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${IMPERSONATION_SA}" \
  -var "billing_account=${BILLING_ACCOUNT}"

gcloud config unset auth/impersonate_service_account
