# AI Platform Notebook Security Blueprint: Protecting PII Data

This repository provides an opinionated way to set up AI Platform Notebook in a secure way using Terraform.

**This is not an officially supported Google product**

## Reference Architecture
![Reference Architecture](diagrams/notebook_blueprint_arch.png)	   	


The resources that this module will create are:

- One AI Platform Notebook per Notebook user
- Service Account for Notebooks
- an HSM key used for Customer Managed Encryption Keys (CMEK) in each Notebook
- Custom Role to restrict exporting data
- Google Cloud Storage bucket with bootstrap code for Notebooks
- Org Policies at the folder that the `trusted-data` project is in
  - `constraints/gcp.resourceLocations`
  - `constraints/iam.disableServiceAccountCreation`
  - `constraints/iam.disableServiceAccountKeyCreation`
  - `constraints/iam.automaticIamGrantsForDefaultServiceAccounts`
  - `constraints/compute.requireOsLogin`
  - `constraints/compute.restrictProtocolForwardingCreationForTypes`
  - `constraints/compute.restrictSharedVpcSubnetworks`

## Prerequisites

- Deploy the [security foundation blueprint](https://github.com/terraform-google-modules/terraform-example-foundation)

## Compatibility

This module is meant for use with Terraform 0.12. Learn how to [upgraded](https://www.terraform.io/upgrade-guides/0-12.html) to the required version.

## Usage

Basic usage of this module is as follows:

```hcl
module "notebooks_blueprint_security" {
  source  = "GoogleCloudPlatform/notebooks-blueprint-security/google"

  vpc_perimeter_regions           = ["US", "DE"]
  vpc_perimeter_policy_name       = "higher_trust_perimeter_policy"
  vpc_perimeter_ip_subnetworks    = ["NETWORK_CIDR"]  # allowed to access VPC-SC perimeters
  zone                            = "us-central1-a"
  resource_locations              = ["in:us-locations", "in:eu-locations"]
  notebook_key_name               = "trusted-data-key"
  dataset_id                      = "sample_ds_for_notebooks"
  notebook_name_prefix            = "trusted-sample"
  bootstrap_notebooks_bucket_name = "notebook_bootstrap"
  default_policy_id               = "12345678"  # likely org id
  project_trusted_analytics       = "trusted-analytics"
  project_trusted_data            = "trusted-data"
  project_trusted_kms             = "trusted-kms"
  trusted_private_network         = "projects/<shared-restricted-prj>/global/networks/<your_vpc>"
  trusted_private_subnet          = "projects/<shared-restricted-prj>/regions/<region>/subnetworks/<your_subnets_for_notebooks>"
  caip_users                      = ["trusted1@example.com", "trusted2@example.com"]
  confid_users                    = ["group:admin@example.com", "group:trusted-users@example.com"]
  trusted_scientists              = ["user:trusted1@example.com", "user:trusted2@example.com"]
}
```

1. Create a tfvars file with the required inputs (see [Inputs](#inputs) section below)
2. `terraform init ` to get the plugins
3. `terraform plan  -var-file="YOUR_FILE.tfvars"` to see the infrastructure plan.  Note: Replace `YOUR_file` with the name of your tfvars file from the first step
4. `terraform apply  -var-file="YOUR_FILE.tfvars"` to apply the infrastructure build. Note: Replace `YOUR_file` with the name of your tfvars file from the first step

5. Access your AI Platform Notebook
    * establish an [SSH tunnel](https://cloud.google.com/ai-platform/notebooks/docs/ssh-access) from your device to your AI Platform Notebook
    * in your browser, visit `http://localhost:8080` to access your AI Platform Notebook

Be sure to specify your `projectName`, `dataset`, and `table` below, which should match your terraform.tfvars file.
```
%%bigquery
SELECT
  *
FROM ‘<projectID>.<dataset>.<table>
LIMIT 10
```

1. `terraform destroy  -var-file="YOUR_FILE.tfvars"` to destroy the built infrastructure. Note: Replace `YOUR_file` with the name of your tfvars file from the first step

### Adding identities to groups
1.  You may need to add service accounts the appropriate IAM high trust data scientist group.
```
# please change the values below to your specific values
gcloud identity groups memberships add --group-email grp-trusted-data-scientists@example.com --member-email = sa-p-notebook-compute@<proj>.iam.gserviceaccount.com
```

### Accessing Notebooks
Use ssh to access your notebook.  Notebooks have no external IP and users should not impersonate the Notebook service account.
Learn how to open an ssh tunnel to launch JuptyerLab, by reading the [SSH to access JupyterLab article](https://cloud.google.com/ai-platform/notebooks/docs/ssh-access).


Functional examples are included in the
[examples](./examples/) directory.


## Inputs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| trusted_private_network | The URI of the private network where you want your Notebooks.  This would be the restricted_network_self_link from the foundational security blueprint terraform  | `string` | `""` | yes |
| trusted_private_subnet | The URI of the private subnet where you want your Notebooks. This would be the restricted_subnets_self_link from the foundational security blueprint terraform | `string` | `""` | yes |
| default\_policy\_id | The parent of this AccessPolicy in the Cloud Resource Hierarchy. As of now, only organization IDs are accepted as parent. | `string` | `""` | yes |
| vpc\_perimeter\_policy\_name | The perimeter policy's name. | `string` | `""` | yes |
| vpc\_perimeter\_ip\_subnetworks | IP subnets allowed to access the higher trust perimeters. | `list(string)` | `[]` | yes |
| vpc\_perimeter\_regions | 2 letter identifier for regions allowed for VPC access. A valid ISO 3166-1 alpha-2 code. | `list(string)` | `[]` | yes |
| project\_trusted\_analytics | Project that holds Notebooks | `string` | `""` | yes |
| project\_trusted\_data | Project that holds data used Notebook | `string` | `""` | yes |
| project\_trusted\_kms | Project that holds KMS keys used to protect PII data for Notebooks | `string` | `""` | yes |
| resource\_locations | Regions where resource can be provisioned | `list(string)` | `[]` | yes |
| vpc\_subnets\_projects\_allowed | list of projects with allowed vpc subnets for the notebooks; defined with the under constraint format (e.g. ["under:projects/project_id1", "under:projects/project_id2"]) | `list(string)` | `[]` | yes |
| notebook\_key\_name | name to use to create a KMS/HSM key that protects pii data | `string` | `""` | yes |
| caip\_users | The list of users that need an AI Platform Notebook (list of emails). | `list(string)` | `[]` | yes |
| trusted\_scientists | The list of trusted scientists (in the form of user:scientist1@example.com) | `list(string)` | `[]` | yes |
| confid\_users | The list of groups with privileged users that can access PII data. (ex: group@example.com) | `list(string)` | `[]` | yes |
| dataset\_id | BigQuery dataset ID with PII data that scientists need access | `string` | `""` | yes |
| notebook\_name\_prefix | Prefix used in provisioning Notebooks in the higher trust boundary. | `string` | `"trusted-sample"` | no |

## Outputs

| Name | Description |
|------|-------------|
| none | none |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.12
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.51

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

Organization Level
- Access Context Manager Policy Admin: `roles/accesscontextmanager.policyAdmin`
- Organization Policy Admin: `roles/orgpolicy.policyAdmin`
- Security Admin: `roles/iam.securityAdmin`
- Service Usage Consumer: `roles/serviceusage.serviceUsageConsumer`

Restricted Shared VPC Project (created in blueprint foundation)
- Network Admin: `compute.networkAdmin`

Analytics Project
- Service Account Creator: `roles/iam.serviceAccountCreator`
- Cloud KMS Admin: `roles/cloudkms.admin`
- Compute Instance Admin: `roles/compute.admin`
- BigQuery Job User: `roles/bigquery.jobUser`
- BigQuery User: `roles/bigquery.user`
- Notebooks Runner: `roles/notebooks.runner`
- Service Account User: `roles/iam.serviceAccountUser`
- Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`

Data Project
- BigQuery Job User: `roles/bigquery.jobUser`
- BigQuery User: `roles/bigquery.user`
- Role Administrator: `roles/iam.roleAdmin`
- Storage Admin: `roles/storage.admin`

KMS Project
- Cloud KMS Admin: `roles/cloudkms.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where analytics and Notebooks reside:

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- BigQuery API: `bigquery.googleapis.com`
- Compute Engine API: `compute.googleapis.com`
- Identity and Access Management (IAM) API: `iam.googleapis.com`
- Key Management Service (KMS) API: `cloudkms.googleapis.com`
- Notebooks (AI Platform) API: `notebooks.googleapis.com`
- Google Cloud Storage API: `storage.googleapis.com`
- Resource Manager API: `cloudresourcemanager.googleapis.com`
- IAM Service Account Credentials API: `iamcredentials.googleapis.com`

In order to operate with the Service Account you must activate the following APIs on the project where your KMS/HSM keys reside:

- Google Cloud Storage API: `storage.googleapis.com`
- Key Management Service (KMS) API: `cloudkms.googleapis.com`


### Resource Hierarchy
Within your Org's prod environment, create a folder to hold your trusted projects and centrally managed your policies for Notebooks that use PII data.
Note: the `fldr-prod` is created by the foundation blueprint.  Create folders by using the [project factory](https://github.com/terraform-google-modules/terraform-google-project-factory)

```
fldr-prod
└── fldr-trusted
    ├── trusted-data
    ├── trusted-analytics
    └── trusted-kms
```


## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html
