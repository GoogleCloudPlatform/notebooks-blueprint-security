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


folder = attribute('trusted_folder')

disable_sa_creation = 'constraints/iam.disableServiceAccountCreation'
disable_sa_key_creation = 'constraints/iam.disableServiceAccountKeyCreation'
auto_iam_grants_for_default_sa = 'constraints/iam.automaticIamGrantsForDefaultServiceAccounts'

control 'gcp_iam_policy' do
  title 'OrgPolicies module constraint tests for IAM constraints'

  describe google_organization_policy(organization_name: folder, constraint: disable_sa_creation ) do
    it { should exist }
    its('constraint') { should eq disable_sa_creation }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: disable_sa_key_creation ) do
    it { should exist }
    its('constraint') { should eq disable_sa_key_creation }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: auto_iam_grants_for_default_sa ) do
    it { should exist }
    its('constraint') { should eq auto_iam_grants_for_default_sa }
    its('boolean_policy.enforced') { should be true }
  end

end


