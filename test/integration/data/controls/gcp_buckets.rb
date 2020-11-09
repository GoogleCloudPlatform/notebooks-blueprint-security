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

gcs_bucket_etl = attribute('bkt_data_etl_name')
gcs_bucket_data = attribute('bkt_data_name')
gcs_bucket_notebooks = attribute('bkt_notebooks_name')

gcs_bucket_region = attribute('bkt_region').upcase
gcs_key_etl = attribute('bkt_data_etl_key_name')
gcs_key_data = attribute('bkt_data_key_name')
gcs_key_notebooks = attribute('bkt_notebooks_key_name')

gcs_bucket_data_project_name = attribute('bkt_data_project_name')
gcs_bucket_data_etl_project_name = attribute('bkt_data_etl_project_name')
gcs_bucket_notebooks_project_name = attribute('bkt_notebooks_project_name')

control 'gcp_data_buckets' do
  title 'Data module GCP resources for Cloud Storage'

  describe google_storage_bucket(name: gcs_bucket_etl) do
    it { should exist }
    its('storage_class') { should eq 'STANDARD' }
    its('location') { should eq gcs_bucket_region }
    its('encryption.default_kms_key_name') { should eq gcs_key_etl }
    
    # TODO add enforcement, when available
    # its('lifecycle.rule.action') { should eq 'Delete' }
    # its('lifecycle.rule.age') { should eq '1' }
  end

  describe google_storage_bucket(name: gcs_bucket_data) do
    it { should exist }
    its('storage_class') { should eq 'STANDARD' }
    its('location') { should eq gcs_bucket_region }
    its('encryption.default_kms_key_name') { should eq gcs_key_data }
  end

  describe google_storage_bucket(name: gcs_bucket_notebooks) do
    it { should exist }
    its('storage_class') { should eq 'STANDARD' }
    its('location') { should eq gcs_bucket_region }
    its('encryption.default_kms_key_name') { should eq gcs_key_notebooks }
  end

end

