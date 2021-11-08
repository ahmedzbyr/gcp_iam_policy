locals {
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

  # minimum set of permission at project level. 
  project_iam = ["DATAPROC", "BIGQUERY", "BIGTABLE", "DATAFLOW"]

  access = [
    {
      resource     = "BIGQUERY"
      subcomponent = "bq_dataset_one"
      permission   = "ADMIN"
    },
    {
      resource     = "BIGQUERY"
      subcomponent = "bq_dataset_two"
      permission   = "DATA_EDITOR"
    },
    {
      resource     = "GCS"
      subcomponent = "gcs_bucket_one"
      permission   = "ADMIN"
    },
    {
      resource     = "BIGTABLE"
      subcomponent = "my_bt_instance"
      permission   = "ADMIN"
    },
    {
      resource     = "PUBSUB_SUBS"
      subcomponent = "my_subs"
      permission   = "ADMIN"
    },
    {
      resource     = "PUBSUB_TOPIC"
      subcomponent = "my_topic"
      permission   = "VIEWER"
    }
  ]

  # This will on be added to the resource which allow conditional IAM policies
  # Rest will ignore this. Currently available on GCS bucket.
  access_conditions = {
    title       = "expires_in_3_months"
    description = "Expires in 3 months"
    expression  = "request.time < timestamp(\"2022-02-01T00:00:00Z\")"
  }

}

module "setup_iam_policy" {
  source                 = "../../modules/iam"
  project                = "driven-lore-328513"
  service_account        = local.service_account
  group_name             = local.group_name
  create_service_account = local.create_service_account

  #
  # mode_authoritative  = true;  "Authoritative" means to change all related privileges for the specific role, (Authoritative: Single source of truth for a given role)
  # mode_authoritative  = false; "non-authoritative" means not to change related privileges, only to change ones you specified. (Additive : Adding permissions to already exsiting policy)
  #
  #   authoritative as the single source of truth for a specific role (other roles which are not specified in the access list are preserved), and 
  #   non-authoritative (additive) is added to existing policies.
  #
  mode_authoritative = local.mode_authoritative # "Authoritative" or "Additive" (defaults to Additive)
  project_iam        = local.project_iam        # minimum set of permission at project level. 
  access             = local.access             # Access permission to each subcomponent in GCP

  # This will on be added to the resource which allow conditional IAM policies
  # Rest will ignore this. 
  access_conditions = local.access_conditions

}

output "sa" {
  value = module.setup_iam_policy.service_account
}
