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
# `bash setup.sh $DEPLOYMENT_PROJECT_ID $ORGANIZATION_ID $POLICY_NAME $BILLING_ACCOUNT`
DEPLOYMENT_PROJECT=${DEPLOYMENT_PROJECT_ID}  # 12346789
PARENT_FOLDER=${PARENT_FOLDER}       # 11112222
ORGANIZATION=${ORGANIZATION_ID}              # 33334444
POLICY_NAME=${POLICY_NAME}                   # 987654321
BILLING_ACCOUNT=${BILLING_ACCOUNT}           # ABCD-2345-GHIJ
SA_NAME="blueprint-terraform-b"

echo "Make sure that you enable a billing account for the project."

#TODO check that the seed project already exists
# gcloud projects create ${DEPLOYMENT_PROJECT} \
#   --organization ${ORGANIZATION} \
#   --billing-project ${DEPLOYMENT_PROJECT}

# gcloud beta billing projects link ${DEPLOYMENT_PROJECT} \
#   --billing-account ${BILLING_ACCOUNT}

# gcloud config set billing/quota_project $DEPLOYMENT_PROJECT

function wait_service_enable() {
  service=""
  attempt=0
  sleeper=1
  while (( $attempt <  10 )); do
    echo "Attempt ${attempt} to test if service $1 is enabled..."
    service=$(gcloud services list --project ${DEPLOYMENT_PROJECT} | grep $1)
    echo "service is ${service}"

    if [ ! -z "$service" ]; then
      echo "Service $1 is enabled."
      break
    else
      echo "Service $1 is still not enabled..."
      attempt=$(( attempt + 1 ))
      sleeper=$(( sleeper * 2 ))
    fi
    sleep ${sleeper}
    echo $attempt
  done

  if [ -z "$service" ];then
    echo "Failed to enabled $1."
  fi
}

gcloud services enable iam.googleapis.com --project ${DEPLOYMENT_PROJECT}
gcloud services enable cloudresourcemanager.googleapis.com --project ${DEPLOYMENT_PROJECT}
gcloud services enable accesscontextmanager.googleapis.com --project ${DEPLOYMENT_PROJECT}
gcloud services enable cloudkms.googleapis.com --project ${DEPLOYMENT_PROJECT}

wait_service_enable "iam.googleapis.com"
wait_service_enable "cloudresourcemanager.googleapis.com"
wait_service_enable "accesscontextmanager.googleapis.com"
wait_service_enable "cloudkms.googleapis.com"

# check if SA already exists
gcloud iam service-accounts list | grep -i ${SA_NAME}
if [[ $? -eq 1 ]]; then
  echo "Create the terraform SA to deploy the trusted environment"
  gcloud iam service-accounts create ${SA_NAME} --display-name ${SA_NAME} --project ${DEPLOYMENT_PROJECT}
fi

echo "Adding admin policies to the terraform SA...."

gcloud projects add-iam-policy-binding ${DEPLOYMENT_PROJECT} \
--member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
--role roles/iam.roleAdmin
echo "....Added project owner role"

# TODO maybe?
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

gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
--member serviceAccount:${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountKeyAdmin
echo "....Added service accout key admin role"

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

# Create local key for the Terraform service account
client_id=$(cat /tmp/key.json | jq -r '.client_id') || key_sa=""
unique_id=$(gcloud iam service-accounts describe ${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com  --format="value(uniqueId)")

echo "client_id for the key is ${client_id}"
echo "unique_id for the service account is ${unique_id}"

if [[ "$client_id" != "${unique_id}" ]]; then
  echo "IDs do not match, creates key file for ${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com in /tmp/key.json..."
  
  rm /tmp/key.json

  gcloud iam service-accounts keys create /tmp/key.json \
    --iam-account ${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com

fi

echo "changing to terraform SA to provision resources"
gcloud auth activate-service-account ${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com \
    --key-file /tmp/key.json

echo " stopping for now"
exit 0


terraform init

# terraform import \
#   -var "org=organizations/${ORGANIZATION}" \
#   -var "default_policy_name=${POLICY_NAME}" \
#   -var "terraform_sa_email=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com" \
#   -var "billing_account=${BILLING_ACCOUNT}" \
#   module.perimeters.google_access_context_manager_service_perimeter.trusted_perimeter_resource \
#   accessPolicies/${POLICY_NAME}/servicePerimeters/restrict_all

# terraform import  \
#   -var "org=organizations/${ORGANIZATION}" \
#   -var "default_policy_name=${POLICY_NAME}" \
#   -var "terraform_sa_email=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com" \
#   -var "billing_account=${BILLING_ACCOUNT}" \
#   module.perimeters.google_access_context_manager_access_level.trusted_access_level \
#   accessPolicies/${POLICY_NAME}/accessLevels/trusted_corp

terraform apply \
  -var-file="terraform.elo.tfvars" \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com" \
  -var "billing_account=${BILLING_ACCOUNT}"