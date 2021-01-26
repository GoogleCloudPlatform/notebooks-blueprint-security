# End to End Security for Cloud AI Platform (CAIP)

This repository provides an opinionated way to set up AI Platform Notebook in a secure way using Terraform.

# Deploying

## Pre Work
1.  Gather the following information
    1.  Your top-level folder that will hold the trusted notebook environment deployed by this terraform
    2.  Your billing account identifier
    3.  Your privileged project that you want to hold the following:
        1.  the privileged terraform service account
        2.  the terraform state
        3.  the KMS keys
    4.  Your Access Context Manager policy used for VPC-SC configuration for your data scientists
        1.  `# gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format json | jq .[].name | sed 's/"//g' | awk '{split($0,a,"/"); print a[2]}'`
        2.  Select your region from where you'd like data scientiests to access data (e.g US; see full list of [access context regions](https://cloud.google.com/access-context-manager/docs/access-level-attributes#regions))
    5.  Create and get tour IAM group and data scientists identities
    6.  Your VPC subnet (CIDR) where you want your notebooks deployed
    7.  Your zone where you want your notebooks deployed
2.  Update the `setup_variables.sh` file with your GCP specific resource information from step 1
3.  Update the `terraform.template.tfvars` file with your GCP specific resource information from step 1

## setup
1.  Setup appropriate environment variables
```
cd terraform
source setup_variables.sh
```

2.  log in with a privileged account that can assigned the noted roles
```
# Note: The setup script needs a privilege account to create a terraform project and service account.
# It will then provision using that SA instead of the privilege identity.
#     - serviceAccountTokenCreator
#     - service account admin
#     - resource manager admin
#     - access context manager admin

gcloud auth login <privilegeId>
```

3.  Run the setup script
```
#Note:  Please run this setup script for a privilege system such as one provisioned on a VM within GCP
./setup.sh
```

4. Access your AI Platform Notebook
    * establish an [SSH tunnel](https://cloud.google.com/ai-platform/notebooks/docs/ssh-access) from your device to your AI Platform Notebook
    * in your browser, visit `http://localhost:8080` to access your AI Platform Notebook

5. Access your PII data from BigQuery
Be sure to specify your projectName and datasetName below, which should match your terraform.tfvars file.

```
%%bigquery
SELECT
  *
FROM ‘<projectName>.<datasetName>.confid_table’
LIMIT 10
```

## Post script
1.  You may need to add service accounts the appropriate IAM high trust data scientist group.
```
# please change the values below to your specific values
gcloud identity groups memberships add --group-email grp-trusted-data-scientists@example.com --member-email = sa-p-notebook-compute@<proj>.iam.gserviceaccount.com
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| trusted_private_network | The URI of the private network where you want your Notebooks.  This would be the restricted_network_self_link from the foundational security blueprint terraform  | `string` | `""` | yes |
| trusted_private_subnet | The URI of the private subnet where you want your Notebooks. This would be the restricted_subnets_self_link from the foundational security blueprint terraform | `string` | `""` | yes |
| default\_policy\_id | The parent of this AccessPolicy in the Cloud Resource Hierarchy. As of now, only organization IDs are accepted as parent. | `string` | `any` | yes |
| vpc\_perimeter\_policy\_name | The perimeter policy's name. | `string` | `""` | yes |
| vpc\_perimeter\_ip\_subnetworks | IP subnets allowed to access the higher trust perimeters. | `list(string)` | `[]` | yes |
| vpc\_perimeter\_projects | Project IDs within the higher trust boundary/ | `list(string)` | `[]` | yes |
| vpc\_perimeter\_regions | 2 letter identifier for regions allowed for VPC access. A valid ISO 3166-1 alpha-2 code. | `list(string)` | `[]` | yes |
| region | The region 2 letter identifier for resources that interact with Notebooks such as keys, storage, BigQuery, etc | `string` | `""` | yes |
| project\_trusted\_kms | Project that holds KMS keys used to protect PII data for Notebooks | `string` | `""` | yes |
| resource\_locations | Regions where resource can be provisioned | `list(string)` | `[]` | yes |
| vpc\_subnets\_projects\_allowed | list of projects with allowed vpc subnets for the notebooks; defined with the under constraint format (e.g. under:projects/project_id) | `list(string)` | `[]` | yes |
| folder\_trusted | Top level folder hosting PII data.  Format should be folder/1234567 | `string` | `""` | yes |

## Outputs

| Name | Description |
|------|-------------|
| keys | map of KMS keys for each kms module.  Lookup by key's name (string) which has a value of the key's self link (string) |
