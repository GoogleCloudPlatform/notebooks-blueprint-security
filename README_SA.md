# Temp README
This will help with the refactor and be combined back into a single README later.

## Requirements

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

Possibly remove due to "pre-requisites" that are already provided to the blueprint as an input
- Security Admin: `roles/iam.securityAdmin`
- Billing User: `roles/billing.user`
- Access Context Manager Policy Admin: `roles/accesscontextmanager.policyAdmin`
- Resource Manager Folder Creator: `roles/resourcemanager.folderCreator`
- Resource Manager Project Creator: `roles/resourcemanager.projectCreator`
- Service Account User: `roles/iam.serviceAccountUser`
- KMS Admin: `roles/cloudkms.admin`


Needed for blueprint:
- Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`
- Service Account Creator: `roles/iam.serviceAccountCreator`
- Compute Admin: `roles/compute.admin`
- BigQuery Job User: `roles/bigquery.jobUser`
- BigQuery User: `roles/bigquery.user`
- Storage Admin: `roles/storage.admin`
- Notebooks Runner: `roles/notebooks.runner`

The [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) may be used in combination to provision a
service account with the necessary roles applied.
