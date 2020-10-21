# End to End Security for Cloud AI Platform (CAIP)

This repository provides an opinionated way to set up AI Platform Notebook in a secure way using Terraform.

# Deplying

## Pre Work
1.  Gather the following information
    1.  Your top-level folder that will hold the trusted notebook environment deployed by this terraform
    2.  Your billing account identifier
    3.  Your project that holds 
        1.  the privileged terraform service account
        2.  the terraform state
        3.  the KMS keys
    4.  Your Access Context Manager policy used for VPC-SC configuration for your data scientists
        1.  Select your region from where you'd like data scientiests to access data
    5.  Your IAM group and data scientists identities
    6.  Your VPC subnet (CIDR) where you want your notebooks deployed
    7.  Your zone where you want your notebooks deployed
2.  Update the `setup_variables.sh` file with your GCP specific resource information from step 1
3.  Update the `terraform.template.tfvars` file with your GCP specific resource information from step 1

## setup
1.  Setup appropriate environment variables
```
source setup_variables.sh
```

2.  log in with a privileged account that can assigned the noted roles
```
cd terraform
# Note: The setup script needs a privilege account to create a terraform project and service account.
# It will then provision using that SA instead of the privilege identity.
#     - service account admin
#     - service account key admin
#     - resource manager admin
#     - access context manager admin
gcloud auth login <privilegeId>
```

3.  Run the setup script
```
#Note:  Please run this setup script for a privilege VM such as one provisioned on a VM within GCP
bash setup.sh $DEPLOYMENT_PROJECT_ID $ORGANIZATION_ID $POLICY_NAME $BILLING_ACCOUNT
```

## Post script
1.  You may need to add service accounts the appropriate IAM groups.
2.  