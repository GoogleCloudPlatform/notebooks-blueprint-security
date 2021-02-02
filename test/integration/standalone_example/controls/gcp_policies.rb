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

folder = attribute('folder_trusted')
included_regions =  attribute('resource_locations')

# constraints to validate
resource_location = 'constraints/gcp.resourceLocations'

control 'gcp_policy' do
  title 'OrgPolicies module constraint tests for gcp constraints'
  only_if('org path fixed') {
    # delete this block once the following error message is fixed.
    #   `error message <code>/v1/:getOrgPolicy?</code> was not found on this server`
    false
  }
  describe google_organization_policy(organization_name: folder, constraint: resource_location ) do
    it { should exist }
    its('constraint') { should eq resource_location }
    its('list_policy.allowed_values') { should include included_regions }
  end
end
