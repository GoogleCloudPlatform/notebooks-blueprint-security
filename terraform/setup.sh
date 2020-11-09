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
TERRAFORM_SA=${TERRAFORM_SA}                 # If this is set, it's most likely a SA used with the foundational blueprint and is a full email

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


IMPERSONATION_SA=""
if [[ -z ${TERRAFORM_SA} ]]; then
    setup_using_new_terraform
    IMPERSONATION_SA=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com
else
    setup_using_foundation_terraform
    IMPERSONATION_SA=${TERRAFORM_SA}
fi

# impersonnate with a token (use cloud identity to set the default time to 1 hr)
# this uses oauth so that a SA key isn't needed
gcloud config set auth/impersonate_service_account ${IMPERSONATION_SA}
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

terraform init

terraform apply \
  -var "org=organizations/${ORGANIZATION}" \
  -var "default_policy_name=${POLICY_NAME}" \
  -var "terraform_sa_email=${IMPERSONATION_SA}" \
  -var "billing_account=${BILLING_ACCOUNT}"
