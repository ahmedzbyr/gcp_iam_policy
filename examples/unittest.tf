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
  project_iam = ["DATAPROC", "BIGQUERY", "BIGTABLE", "DATAFLOW", "GCS", "PUBSUB"]

  access = [
    {
      product    = "BIGQUERY"
      component  = "bq_dataset_one"
      permission = "ADMIN"
    },
    {
      product    = "BIGQUERY"
      component  = "bq_dataset_two"
      permission = "DATA_EDITOR"
    },
    {
      product    = "DATAPROC"
      component  = "dp_cluster_instance_one"
      permission = "EDITOR"
    },
    {
      product    = "GCS"
      component  = "gcs_bucket_one"
      permission = "EDITOR"
    }



  ]

  # This will on be added to the resource which allow conditional IAM policies
  # Rest will ignore this. Currently available on GCS bucket.
  access_conditions = {
    title       = "expires_in_3_months"
    description = "Expires in 3 months"
    expression  = "request.time < timestamp(\"2022-02-01T00:00:00Z\")"
  }

  acc_service_account = flatten([
    for access_items in local.access : [
      for sa in local.service_account : merge(access_items, local.access_conditions, { service_account = sa })
    ]
  ])

  acc_groups = flatten([
    for access_items in local.access : [
      for grps in local.group_name : merge(access_items, local.access_conditions, { group = grps })
    ]
  ])

  authoritative_members_sa   = [for sa in local.service_account : "serviceAccount:${sa}"]
  authoritative_members_grps = [for grps in local.group_name : "group:${grps}"]
  authoritative_members      = concat(local.authoritative_members_sa, local.authoritative_members_grps)


  iam_project_members = { for items in distinct([for items in local.acc_service_account : { product = items.product, service_account = items.service_account }]) : "${items.product}-${items.service_account}" => items }

  #
  # BIGQUERY
  #
  bq_sa_permissions       = { for bq_perms in local.acc_service_account : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.service_account}" => bq_perms if bq_perms.product == "BIGQUERY" }
  bq_grps_permissions     = { for bq_perms in local.acc_groups : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.group}" => bq_perms if bq_perms.product == "BIGQUERY" }
  bq_authoritative_access = { for bq_perms in local.access : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.component}" => bq_perms if bq_perms.product == "BIGQUERY" }

  #
  # BIGTABLE
  #
  bt_sa_permissions = {
    for bq_perms in local.acc_service_account : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.service_account}" => bq_perms if bq_perms.product == "BIGTABLE"
  }

  bt_grps_permissions = {
    for bq_perms in local.acc_groups : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.group}" => bq_perms if bq_perms.product == "BIGTABLE"
  }



}



