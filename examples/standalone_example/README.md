# Standalone Example

This example illustrates how to use the `notebooks-blueprint-security` blueprint.

It requires a BigQuery table with sample PII data.  An example is provisioned as part of the testing specified in `/test/setup`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc\_perimeter\_ip\_subnetworks | IP subnets allowed to access the higher trust perimeters. | `list(string)` | `[]` | yes |
| default\_policy\_id | The parent of this AccessPolicy in the Cloud Resource Hierarchy. As of now, only organization IDs are accepted as parent. | `string` | `""` | yes |
| project\_trusted\_analytics | Project that holds Notebooks | `string` | `""` | yes |
| project\_trusted\_data | Project that holds data used Notebook | `string` | `""` | yes |
| project\_trusted\_kms | Project that holds KMS keys used to protect PII data for Notebooks | `string` | `""` | yes |
| trusted_private_network | The URI of the private network where you want your Notebooks.  This would be the restricted_network_self_link from the foundational security blueprint terraform  | `string` | `""` | yes |
| trusted_private_subnet | The URI of the private subnet where you want your Notebooks. This would be the restricted_subnets_self_link from the foundational security blueprint terraform | `string` | `""` | yes |
| caip\_users | The list of users that need an AI Platform Notebook (list of emails). | `list(string)` | `[]` | yes |
| trusted\_scientists | The list of trusted scientists (in the form of user:scientist1@example.com) | `list(string)` | `[]` | yes |
| confid\_users | The list of groups with privileged users that can access PII data. (ex: group@example.com) | `list(string)` | `[]` | yes |
| dataset\_id | BigQuery dataset ID with PII data that scientists need access | `string` | `""` | yes |
| zone | The zone in which to create the secured notebook. Must match the region | `string` | `""` | yes |

## Outputs

| Name | Description |
|------|-------------|
| none | none |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
