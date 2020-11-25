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

# Note: The items in this file represent decisions you will have to make prior to deploying;
# thus no default values are specified here.  Any defaults would be specified in the variables.tf file
# Once all the values are provided, the trusted environment can be deployed

default_billing_project_id = "YOUR_PROJECT_ID" # "123456789" default projectID in case resources do not have a project specified
zone                       = "YOUR_ZONE"       # e.g. "us-central1-a"
region                     = "YOUR_GEO"        # e.g. "us"

# Used for network creation.  Use location names for the networking resource
region_trusted_network = "YOUR_REGION" # e.g. "us-central1"

# list of locations where resources can be deployed.  valid value groups: https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations#value_groups
resource_locations        =  []  # e.g. "in:us-locations"

# parent_env is a top level environment folder such as production where you'd like the `folder_trusted` to be created under
parent_env = "YOUR_PARENT_FOLDER" # e.g. "folders/123456789"

# This creates a folder in your parent_env (e.g production environment) that will hold all projects with higher trust data
folder_trusted = "YOUR_FOLDER_NUMBER" # "folder-abc-def"

# This is the privileged environment where KMS will be created
bootstrap_env             = "YOUR_FOLDER"    # "folders/12345678"

# These are the individual project names for resources that touch higher trust data.
# These will be used by the structure module to create the projects.
project_trusted_analytics = "YOUR_PROJECT" # "abcd"
project_trusted_data      = "YOUR_PROJECT" # "efgh"
project_trusted_data_etl  = "YOUR_PROJECT" # "ijkl"
project_trusted_kms       = "YOUR_PROJECT" # "mnop"
project_networks          = "YOUR_PROJECT" # "qrst" This is likely the same as your project_trusted_analytics project name

# These identities are assigned a customer view data role in BigQuery (i.e the dataViewer role)
# It is preferred to create and use a group for data scientist that can access higher trust data
#
# If you use a group, manually add users and the Notebook Service account into the group
# Note: gcloud identity groups memberships add --group-email grp-trusted-data-scientists@example.com --member-email = sa-p-notebook-compute@<proj>.iam.gserviceaccount.com
confid_users = [] # ["group:group-confid1@example.com", "user:confid1@example.com"]

# List of identities that gets a notebook.  Each identity specified gets a Notebook.
# The users list should be the same except for formating (note the "user:" type specification)
# Notebooks do not require the type prefix of user.
# To allow the User to use the console UI to launch their notebook, need the IAM policy format, which requires a type.
caip_users         = [] # ["user1@example.com", "user2@example.com"]
trusted_scientists = [] # ["user:trusted1@example.com", "user:trusted2@example.com"]

# List of CIDRs allowed to access VPC-SC perimeter for your data scientists
perimeters_ip_subnetworks = [] # ["10.10.1.0/24"] should be your internal and trusted network
