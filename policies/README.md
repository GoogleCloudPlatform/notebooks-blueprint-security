# Policy Constraints
Use [config validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md) to enforce policies.

## Before you being

1.  install [terraform validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator)
2.  [install kpt](https://googlecontainertools.github.io/kpt/installation/)
    1.  `sudo apt-get install google-cloud-sdk-kpt`
3.  Edit the `validate.sh` file with appropriate environment values

## Running validation
```sh
./validate.sh
```

This script does the following:
1.  setup environment variables so a terraform plan can be created
2.  create a Kptfile
3.  updates all the constraint yaml files with values for the environment
4.  validates the terraform plan using policy constraints
