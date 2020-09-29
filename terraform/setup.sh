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
# bash setup.sh PROJECT_ID ORGANIZATION_ID POLICY_NAME BILLING_ACCOUNT

PROJECT=$1
ORGANIZATION=$2     # 123456789
POLICY_NAME=$3      # 987654321
BILLING_ACCOUNT=$4  # ABCD-2345-GHIJ
SA_NAME="terraform"

echo "Make sure that you enable a billing account for the project."

gcloud projects create ${PROJECT} \
  --organization ${ORGANIZATION} \
  --billing-project ${PROJECT}

gcloud beta billing projects link ${PROJECT} \
  --billing-account ${BILLING_ACCOUNT}

gcloud config set billing/quota_project $PROJECT

function wait_service_enable() {
  service=""
  attempt=0
  sleeper=1
  while (( $attempt <  10 )); do
    echo "Attempt ${attempt} to test if service $1 is enabled..."
    service=$(gcloud services list --project ${PROJECT} | grep $1)
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

gcloud services enable iam.googleapis.com --project ${PROJECT}
gcloud services enable cloudresourcemanager.googleapis.com --project ${PROJECT}
gcloud services enable accesscontextmanager.googleapis.com --project ${PROJECT}

wait_service_enable "iam.googleapis.com"
wait_service_enable "cloudresourcemanager.googleapis.com"
wait_service_enable "accesscontextmanager.googleapis.com"

exit 0

gcloud iam service-accounts create terraform --display-name ${SA_NAME} --project ${PROJECT}

gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/accesscontextmanager.policyAdmin

gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/resourcemanager.organizationAdmin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/serviceusage.serviceUsageAdmin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/secretmanager.admin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/compute.admin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/iam.securityAdmin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/iam.roleAdmin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountCreator

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/bigquery.jobUser

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/cloudkms.admin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/bigquery.user

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/storage.admin

gcloud projects add-iam-policy-binding ${PROJECT} \
--member serviceAccount:${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
--role roles/notebooks.runner

# Create local key for the Terraform service account
client_id=$(cat /tmp/key.json | jq -r '.client_id') || key_sa=""
unique_id=$(gcloud iam service-accounts describe ${SA_NAME}@${PROJECT}.iam.gserviceaccount.com  --format="value(uniqueId)")

echo "client_id for the key is ${client_id}"
echo "unique_id for the service account is ${unique_id}"

if [[ "$client_id" != "${unique_id}" ]]; then
  echo "IDs do not match, creates key file for ${SA_NAME}@${PROJECT}.iam.gserviceaccount.com in /tmp/key.json..."
  
  rm /tmp/key.json

  gcloud iam service-accounts keys create /tmp/key.json \
    --iam-account ${SA_NAME}@${PROJECT}.iam.gserviceaccount.com

  # gcloud auth activate-service-account ${SA_NAME}@${PROJECT}.iam.gserviceaccount.com \
  #   --key-file /tmp/key.json
fi

terraform init

terraform import \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
  -var "billing_account=${BILLING_ACCOUNT}" \
  module.perimeters.google_access_context_manager_service_perimeter.trusted_perimeter_resource \
  accessPolicies/${POLICY_NAME}/servicePerimeters/restrict_all

terraform import  \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
  -var "billing_account=${BILLING_ACCOUNT}" \
  module.perimeters.google_access_context_manager_access_level.trusted_access_level \
  accessPolicies/${POLICY_NAME}/accessLevels/trusted_corp

terraform apply \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${SA_NAME}@${PROJECT}.iam.gserviceaccount.com" \
  -var "billing_account=${BILLING_ACCOUNT}"