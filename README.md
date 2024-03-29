# GCP IAM Policy Setup 

**Work in Progress**

This module can be used to setup GCP IAM policy for a `service_account` or `group`. 
Idea is to setup service accounts quickly with permissions required for it to run a workflow. 

## Input Parameters     

| Name                     | Description                                                                                   | Type | Default | Required |
| ------------------------ | --------------------------------------------------------------------------------------------- | ---- | ------- | :------: |
| `service_account`        | A list of service account, which needs to have the permissions                                | list | None    |   Yes    |
| `create_service_account` | Flag to create service account in the above `service_account` list                            | bool | false   |    No    |
| `group_name`             | A list of groups, which needs to have the permissions                                         | list | []      |    No    |
| `mode_authoritative`     | mode_authoritative  = true;  "Authoritative", Else "Non Authoritative"                        | bool | false   |    No    |
| `project_iam`            | A list project level minimum access permissions                                               | list | []      |    No    |
| `access`                 | A list of key/value information about the permission required for the servivce account/ group | list |         |   Yes    |
| `access_conditions`      | A map which has the access conditions, currently only used by storage bucket.                 | map  | {}      |    No    |

## Example

### Basic parameters

```hcl
  service_account        = ["my-test-service-account@google-serive-account.com", "my-test-service-account2@google-serive-account.com"]
  create_service_account = false
  group_name             = ["my_first_group@google.com", "my_second_group@google.com", "my_third_group@google.com"]

  #
  # mode_authoritative  = true;  "Authoritative" means to change all related privileges for the specific role, (Authoritative: Single source of truth for a given role)
  # mode_authoritative  = false; "non-authoritative" means not to change related privileges, only to change ones you specified. (Additive : Adding permissions to already exsiting policy)
  #
  #   authoritative as the single source of truth for a specific role (other roles which are not specified in the access list are preserved), and 
  #   non-authoritative (additive) is added to existing policies.
  #
  mode_authoritative = false
```

### `project_iam`

```hcl
  # minimum set of permission at project level. 
  project_iam = ["DATAPROC", "BIGQUERY", "BIGTABLE", "DATAFLOW"]
```

### `access`

```hcl
  access = [
    {
      resource    = "BIGQUERY"
      subcomponent  = "bq_dataset_one"
      permission = "ADMIN"
    },
    {
      resource    = "BIGQUERY"
      subcomponent  = "bq_dataset_two"
      permission = "DATA_EDITOR"
    },
    {
      resource    = "GCS"
      subcomponent  = "gcs_bucket_one"
      permission = "ADMIN"
    },
    {
      resource    = "BIGTABLE"
      subcomponent  = "my_bt_instance"
      permission = "ADMIN"
    },
    {
      resource    = "PUBSUB_SUBS"
      subcomponent  = "my_subs"
      permission = "ADMIN"
    },
    {
      resource    = "PUBSUB_TOPIC"
      subcomponent  = "my_topic"
      permission = "VIEWER"
    }
  ]
```

### `access_conditions`

```hcl 
  # This will on be added to the resource which allow conditional IAM policies
  # Rest will ignore this. Currently available on GCS bucket.
  access_conditions = {
    title       = "expires_in_3_months"
    description = "Expires in 3 months"
    expression  = "request.time < timestamp(\"2022-02-01T00:00:00Z\")"
  }
```

### Example to Run

```hcl
module "setup_iam_policy" {
  source                 = "../../modules/iam"
  project                = "driven-lore-328513"
  service_account        = local.service_account
  group_name             = local.group_name
  create_service_account = local.create_service_account
  mode_authoritative     = local.mode_authoritative # "Authoritative" or "Additive" (defaults to Additive)
  project_iam            = local.project_iam        # minimum set of permission at project level. 
  access                 = local.access             # Access permission to each subcomponent in GCP
  access_conditions      = local.access_conditions
}
```



