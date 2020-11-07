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

bq_dataset_id = attribute('bq_dataset_dataset_id')
bq_prj = attribute('bq_dataset_project_id')
bq_table_id = attribute('bq_table_id')
bq_table_num_rows = attribute('bq_table_num_rows')


# BQ has to be in the same region as GCS and the KMS keys
gcp_region = attribute('bkt_region').upcase

# the BQ KMS should match the data key used for GCS
key_data = attribute('bkt_data_key_name')


control 'gcp_data_bigquery' do
  title 'Data module GCP resources for BigQuery'

  describe google_bigquery_dataset(project: bq_prj, name: bq_dataset_id) do
    it { should exist }
  
    its('default_encryption_configuration.kms_key_name') { should eq key_data }
    its('location') { should eq gcp_region }
  end

  describe google_bigquery_table(project: bq_prj, dataset: bq_dataset_id, name: bq_table_id) do
    it { should exist }
    its('num_rows') { should == bq_table_num_rows }
  end
end

