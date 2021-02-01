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

kms_project_id = attribute('kms_project_id')

kms_zone = attribute('zone')
kms_region = kms_zone.split(/-/)[0]

kms_key_ring_name = attribute('notebook_key_ring_name')
kms_higher_trust_data_key_name = attribute('notebook_key_name').split('/').last

control 'gcp_kms' do
  title 'KMS module GCP resources'

  describe google_kms_key_ring(project: kms_project_id, location: kms_region, name: kms_key_ring_name) do
    it { should exist }
    its('key_ring_name'){ should eq kms_key_ring_name }
    #its('location') { should eq kms_region }
  end

  # greater than 45 days
  describe google_kms_crypto_key(project: kms_project_id, location: kms_region, key_ring_name: kms_key_ring_name, name: kms_higher_trust_data_key_name) do
    it { should exist }
    its('crypto_key_name') { should cmp kms_higher_trust_data_key_name }
    its('primary_state') { should eq "ENABLED" }
    its('purpose') { should eq "ENCRYPT_DECRYPT" }

    # assume resource created witin 24 hrs
    its('next_rotation_time') { should be > Time.now + 3888000 - 24*60*60 }
    its('version_template.protection_level') { should eq "HSM"}
  end
end

