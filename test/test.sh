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

# `source test/setup_variables.sh && ./test/test.sh`


IMPERSONATION_SA=""
if [[ -z ${TERRAFORM_SA} ]]; then
    IMPERSONATION_SA=${SA_NAME}@${DEPLOYMENT_PROJECT}.iam.gserviceaccount.com
else
    IMPERSONATION_SA=${TERRAFORM_SA}
fi

# Impersonnate with a token
gcloud config set auth/impersonate_service_account ${IMPERSONATION_SA}
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

# Test against CIS benchmark
PROJECT_LIST=(
  ${PRJ_HIGH_TRUST_ANALYTICS}
  ${PRJ_HIGH_TRUST_DATA}
  ${PRJ_HIGH_TRUST_DATA_ETL}
  ${PRJ_HIGH_TRUST_KMS}
)

# Run CIS on all projects created
for PRJ in "${PROJECT_LIST[@]}"
do
  inspec exec https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark.git -t gcp:// --input gcp_project_id=${PRJ} --reporter cli json:${PRJ}_scan.json
done

# Run all kitchen-terraform tests
kitchen destroy

kitchen create

kitchen converge

kitchen verify

kitchen destroy

gcloud config unset auth/impersonate_service_account

gcloud config unset auth/impersonate_service_account
