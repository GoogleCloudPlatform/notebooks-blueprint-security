# End to End Security for Cloud AI Platform (CAIP)

This repository provides an opinionated way to set up AI Platform Notebook in a secure way using Terraform.

# setup

```
PROJECT=[YOUR_PROJECT_ID]               # example-project
ORGANIZATION=[YOUR_ORGANIZATION_ID]     # 123456789
POLICY_NAME=[YOUR_POLICY_NAME]          # 987654321
BILLING_ACCOUNT=[YOUR_BILLING_ACCOUNT]  # ABCD-2345-GHIJ

cd terraform

bash setup.sh $PROJECT_ID $ORGANIZATION_ID $POLICY_NAME $BILLING_ACCOUNT
```

