# Temp README for INPUT/OUTPUT
This will be merged into the main README after refactor to cookiecutter

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
| data\_key | KMS/HSM key URI protecting pii data | `string` | `""` | yes |
| confid\_users | The list of groups with privileged users that can access PII data | `list(string)` | `[]` | yes |

## Outputs

| Name | Description |
|------|-------------|
| none | none |
