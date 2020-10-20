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

# org                       = "[YOUR_ORG]"              # "organizations/123456789"
# default_policy_name       = "[YOUR_POLICY]"           # "9876543210"
# billing_account           = "[YOUR_BILLING_ACCOUNT]"  # "12345A-45678B-15926C"

default_billing_project   = "[YOUR_PROJECT_ID]"       # "123456789" default projectID in case resources do not have a project specified
zone                      = "[YOUR_ZONE]"             # "us-central1-a"
region                    = "[YOUR_GEO]"              # "us"
region_trusted_network    = "[YOUR_REGION]"           # "us-central1"
parent_env                = "[YOUR_PARENT_FOLDER]"    # "folders/612796533052"
folder_trusted            = "[YOUR_FOLDER_NUMBER]"    # "[folder-abc-def]"
project_trusted_analytics = "[YOUR_PROJECT]"          # "abcd"
project_trusted_data      = "[YOUR_PROJECT]"          # "efgh"
project_trusted_data_etl  = "[YOUR_PROJECT]"          # "ijkl"
project_trusted_kms       = "[YOUR_PROJECT]"          # "mnop"
project_networks          = "[YOUR_PROJECT]"          # "qrst"
confid_users              = "[YOUR_CONFID_IDENTITY]"  # ["group:group-confid1@example.com", "user:confid1@example.com"]
caip_users                = "[YOUR_CAIP_USERS]"       # ["user1@example.com", "user2@example.com"]
trusted_scientists        = "[YOUR_CAIP_USERS]"       # ["user:trusted1@example.com", "user:trusted2@example.com"]
perimeters_ip_subnetworks = "[YOUR_SUBNETS]"          # ["10.100.32.0/21"] to allow access to resourcees within VPC-SC perimeter