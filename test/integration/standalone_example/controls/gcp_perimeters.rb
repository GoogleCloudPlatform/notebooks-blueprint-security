# Copyright 2021 Google LLC
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

vpc_restricted_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "notebooks.googleapis.com",
    "bigquery.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
vpc_policy_name = attribute('default_policy_id')
vpc_access_level_name = attribute('access_level_name')
vpc_perimeter_name = attribute('perimeter_name')
vpc_resources_within_perimieter = attribute('vpc_perimeter_protected_resources')

puts vpc_resources_within_perimieter

control 'gcp_perimeters' do
  title 'VPC-Service Control perimeters GCP resources'
  describe.one do
    describe google_access_context_manager_service_perimeter(policy_name: vpc_policy_name, name: vpc_perimeter_name) do
      it { should exist }

      vpc_resources_within_perimieter.each do |projects|
        its('status.resources') { should include projects }
      end

      its('status.access_levels') { should include vpc_access_level_name }

      vpc_restricted_services.each do |service|
        its('status.restricted_services') { should include service }
      end
    end
  end
end

