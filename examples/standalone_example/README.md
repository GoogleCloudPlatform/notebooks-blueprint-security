# Standalone Example

This example illustrates how to use the `notebooks-blueprint-security` blueprint.

It requires a BigQuery table with sample PII data.  An example is provisioned as part of the testing specified in `/test/setup`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| confidential\_groups | The list of groups allowed to access PII data. | `list(string)` | n/a | yes |
| dataset\_id | The BigQuery data for notebooks. | `string` | n/a | yes |
| default\_policy\_id | The id of the default org policy. | `string` | n/a | yes |
| project\_trusted\_analytics | The trusted project for analytics activities and data scientists. | `string` | n/a | yes |
| project\_trusted\_data | The trusted project for data used by notebooks. | `string` | n/a | yes |
| project\_trusted\_kms | Top trusted project for encryption keys. | `string` | n/a | yes |
| trusted\_private\_network | Network for Notebooks.  Should be a restricted private VPC. | `string` | n/a | yes |
| trusted\_private\_subnet | Subnet with no external IP for Notebooks.  Should be part of a restricted private network. | `string` | n/a | yes |
| trusted\_scientists | The list of trusted users. | `list(string)` | n/a | yes |
| vpc\_perimeter\_ip\_subnetworks | IP subnets for perimeters. | `list(string)` | n/a | yes |
| zone | The zone in which to create the secured notebook. Must match the region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| access\_level\_name | Access level policy name. |
| bkt\_notebooks\_name | Name of bootstrap bucket. |
| caip\_sa\_email | Email of the SA used by CAIP; should not be a default SA. |
| default\_policy\_id | Access level policy id (i.e organization id). |
| folder\_trusted | Folder that holds all the trusted projects and constraints. |
| notebook\_instances | List of notebooks created (vm names). |
| notebook\_key\_name | Key name used to protect notebooks. |
| notebook\_key\_ring\_name | Name of keyring protecting notebooks. |
| perimeter\_name | Perimeter name used to protect the notebooks. |
| resource\_locations | Name of regions expected in org policy. |
| script\_name | Name of the post startup script installed. |
| vpc\_perimeter\_protected\_resources | List of projects included in the VPC-Sc perimeter. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
