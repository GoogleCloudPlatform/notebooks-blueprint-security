# AI Platform Notebooks Blueprint (standalone)

These instructions allow you to deploy the AI Platform Notebook blueprint in standalone mode on top of your existing deployments.

## Pre Work
Gather the following information:
1.  Your top-level folder that will hold the trusted notebook environment deployed by this terraform
2.  Your billing account identifier
3.  Your privileged project that you want to hold the following:
    1.  the privileged terraform service account
    2.  the terraform state
    3.  the KMS keys
4.  Your Access Context Manager policy ID used for VPC-SC configuration for your data scientists
Note: consider using this gcloud command
```
gcloud access-context-manager policies list --organization ${ORGANIZATION_ID} --format json | jq .[].name | sed 's/"//g' | awk '{split($0,a,"/"); print a[2]}'
```
5.  Select your region from where you'd like data scientists to access data (e.g US; see full list of [access context regions](https://cloud.google.com/access-context-manager/docs/access-level-attributes#regions))
6.  [Create your IAM group](https://cloud.google.com/iam/docs/groups-in-cloud-console) for trusted data scientists identities
7.  Your VPC subnet (CIDR) where you want your notebooks deployed
8.  Your zone where you want your notebooks deployed

Update the appropriate templates with the values from above
1.  Update the `setup_variables.sh` file with your GCP specific resource information from step 1
2.  Copy the `terraform.template.tfvars` to a file named `terraform.tfvars`
```
cp terraform.template.tfvars terraform.tfvars
```
3.  Edit the `terraform.tfvars` file with your GCP specific resource information from step 1

## setup
1.  Setup appropriate environment variables
```
source standalone_setup_variables.sh
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

## Deploy Resources and Access your secured AI Platform Notebooks
1.  Run the setup script
```
# IMPORTANT:  Please run this setup script from a privilege system that normally provisions resources for your production environment
./standalone_setup.sh
```
2. Access your AI Platform Notebook
    * Note:  The VPC-SC perimeter prevents access through the GCP console.
    1. Establish an [SSH tunnel](https://cloud.google.com/ai-platform/notebooks/docs/ssh-access) from your device to your AI Platform Notebook
    2. In your browser, visit `http://localhost:8080` to access your AI Platform Notebook

3. Access your PII data within your AI Platform Notebook  
    1.  create a new Python3 notebook
    2.  provide the following into a cell
        *  Note:  Be sure to replace `<projectName>` and `<datasetName>` to match your values within your `terraform.tfvars` file.
```
%%bigquery
SELECT
  *
FROM ‘<projectName>.<datasetName>.confid_table’
LIMIT 10
```

## Common issues

### Cannot create an SSH tunnel to your notebook
1.  Confirm the identity has the `Compute OS Login` and `Service Usage Consumer` roles

### Notebook cannot access BigQuery data
1.  You must add the notebook's service accounts the appropriate IAM high trust data scientist group.
```
# please change the values below to your specific values
gcloud identity groups memberships add --group-email grp-trusted-data-scientists@example.com --member-email = sa-p-notebook-compute@<proj>.iam.gserviceaccount.com
```
