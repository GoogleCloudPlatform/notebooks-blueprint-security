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

# constraints to validate
vm_external_ip_access = 'constraint/compute.vmExternalIpAccess'
skip_default_network_creation = 'constraints/compute.skipDefaultNetworkCreation'
disable_serial_port_access = 'constraints/compute.disableSerialPortAccess'
disable_serial_port_logging = 'constraints/compute.disableSerialPortLogging'
require_os_login = 'constraints/compute.requireOsLogin'
restrict_shared_vpc_subnetworks = 'constraints/compute.restrictSharedVpcSubnetworks'
restrict_protocol_forwarding_creation_for_types = 'constraints/compute.restrictProtocolForwardingCreationForTypes'


control 'gcp_compute_policy' do
  title 'OrgPolicies module constraint tests for compute constraints'

  only_if('org path fixed') {
    # delete this block once the following error message is fixed.
    #   `error message <code>/v1/:getOrgPolicy?</code> was not found on this server`
    false
  }

  describe google_organization_policy(organization_name: folder, constraint: vm_external_ip_access ) do
    it { should exist }
    its('constraint') { should eq vm_external_ip_access }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: skip_default_network_creation ) do
    it { should exist }
    its('constraint') { should eq skip_default_network_creation }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: disable_serial_port_access ) do
    it { should exist }
    its('constraint') { should eq disable_serial_port_access }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: disable_serial_port_logging ) do
    it { should exist }
    its('constraint') { should eq disable_serial_port_logging }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: require_os_login ) do
    it { should exist }
    its('constraint') { should eq require_os_login }
    its('boolean_policy.enforced') { should be true }
  end

  describe google_organization_policy(organization_name: folder, constraint: restrict_shared_vpc_subnetworks ) do
    it { should exist }
    its('constraint') { should eq restrict_shared_vpc_subnetworks }
    its('list_policy.allowed_values') { should include included_vpc_subnet_projects }
  end

  describe google_organization_policy(organization_name: folder, constraint: restrict_protocol_forwarding_creation_for_types ) do
    it { should exist }
    its('constraint') { should eq restrict_protocol_forwarding_creation_for_types }
    its('list_policy.allowed_values') { should include "is:INTERNAL" }
  end

end
