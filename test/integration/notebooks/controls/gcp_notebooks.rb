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

nbk_project_id = attribute('project_id')
nbk_zone = attribute('zone')
nbk_instances = attribute('notebook_instances')
caip_sa_email = attribute('caip_sa_email')
script_name = attribute('script_name')

kms_key_name = attribute('notebook_key_name')

control 'gcp_notebooks' do
  title 'Notebooks module GCP resources'

  nbk_instances.each do |instance|
    describe google_compute_instance(project: nbk_project_id, zone: nbk_zone, name: instance) do
      it { should exist }
      its('metadata_keys') { should include 'proxy-mode' }
      its('metadata_values') { should include 'mail' }
      its('metadata_keys') { should include 'notebook-disable-root' }
      its('metadata_values') { should include 'true' }
      its('metadata_keys') { should include 'notebook-disable-downloads' }
      its('metadata_values') { should include 'true' }
      its('metadata_keys') { should include 'notebook-disable-nbconvert' }
      its('metadata_values') { should include 'true' }
      its('metadata_keys') { should include 'enable-oslogin' }
      its('metadata_values') { should include 'TRUE' }
      its('metadata_keys') { should include 'post-startup-script' }
      its('metadata_values') { should include script_name[0] }
      its('metadata_keys') { should include 'serial-port-enable' }
      its('metadata_values') { should include 'FALSE' }
      its('metadata_keys') { should include 'block-project-ssh-keys' }
      its('metadata_values') { should include 'TRUE' }
     
      # TODO add additional checks
      #its('disks.disk_encryption_key.kms_key_name') { should be kms_key_name }
      #its('first_network_interface_nat_ip_exists'){ should_not exist }
      #its('service_accounts.email') { should include caip_sa_email }
    end
  end
end

