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

default_billing_project_id = "YOUR_PROJECT_ID" # "123456789" default projectID in case resources do not have a project specified
zone                       = "YOUR_ZONE"       # "us-central1-a"
region                     = "YOUR_GEO"        # "us"

# Used for network creation.  Use location names for the networking resource
region_trusted_network = "YOUR_REGION" # "us-central1"

# parent_env is a top level environment folder such as production where you'd like the `folder_trusted` to be created under
parent_env = "YOUR_PARENT_FOLDER" # "folders/612796533052"

# This creates a folder in your parent_env (e.g production environment) that will hold all projects with higher trust data
folder_trusted = "YOUR_FOLDER_NUMBER" # "folder-abc-def"

# These are the individual projects for resources that touch higher trust data.
project_trusted_analytics = "YOUR_PROJECT" # "abcd"
project_trusted_data      = "YOUR_PROJECT" # "efgh"
project_trusted_data_etl  = "YOUR_PROJECT" # "ijkl"
project_trusted_kms       = "YOUR_PROJECT" # "mnop"
project_networks          = "YOUR_PROJECT" # "qrst" This is likely the same as your project_trusted_analytics project name

# These identities are assigned a customr view data role in BigQuery (i.e the dataViewer role)
# It is preferred to create and use a group for data scientiest that can access higher trust data
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

# List of CIDRs allowed to access VPC-SC perimeter
perimeters_ip_subnetworks = [] # ["1.2.3.4/32"] 

# List of projects to include within a trusted VPC-SC perimeter
# (optional) only uncomment if did not deploy the module.structure  This terraform will auto create all the necessary projects for you.
#perimeter_projects        = []   ["projects/123456", "projects/789456"]
