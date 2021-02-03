#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "#!/usr/bin/env bash" > ../source.sh

example_zone=$(terraform output example_zone)
echo "export TF_VAR_zone='${example_zone}'" >> ../source.sh

example_vpc=$(terraform output example_vpc)
example_vpc_subnet=$(terraform output example_vpc_subnet)
echo "export TF_VAR_trusted_private_network='${example_vpc}'" >> ../source.sh
echo "export TF_VAR_trusted_private_subnet='${example_vpc_subnet}'" >> ../source.sh

example_dataset_id=$(terraform output dataset_id)
echo "export TF_VAR_dataset_id='${example_dataset_id}'" >> ../source.sh

# TODO use token when https://github.com/inspec/inspec-gcp/issues/282 is added
sa_json=$(terraform output sa_key)
# shellcheck disable=SC2086
echo "export SERVICE_ACCOUNT_JSON='$(echo $sa_json | base64 --decode)'" >> ../source.sh
