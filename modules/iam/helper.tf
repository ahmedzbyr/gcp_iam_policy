#
# Creating required maps and list for downstream resources to consume. 
# We have 2 sets if variables which are created based on the flags set. 
#    "Authoritative" and "Non-Authoritative"
# This is done based on the `mode_authoritative` variable. 
#
locals {

  # Adding this to make is more readable.
  authoritative     = var.mode_authoritative
  non_authoritative = var.mode_authoritative == false

  # Creating a service map for all the service accounts.
  acc_service_account = flatten([
    for access_items in var.access : [
      for sa in var.service_account : merge(access_items, { condition = var.access_conditions }, { service_account = sa })
    ]
  ])

  # Creating a group map for all the groups.
  acc_groups = flatten([
    for access_items in var.access : [
      for grps in var.group_name : merge(access_items, { condition = var.access_conditions }, { group = grps })
    ]
  ])

  # Creating a map for service accounts to be created.
  service_accounts_to_create = var.create_service_account ? { for sa in var.service_account : sa => { service_account = split("@", sa)[0] } } : {}

  # Project level minimum permissions
  project_iam_members_permissions = { for srvs in distinct([for srvs in local.acc_service_account : { resource = srvs.resource, service_account = srvs.service_account }]) : "${srvs.resource}-${srvs.service_account}" => srvs if contains(var.project_iam, srvs.resource) }

  # Getting  authoritative_members ready if the mode_authoritative is set to true
  authoritative_members_sa   = [for sa in var.service_account : "serviceAccount:${sa}"]
  authoritative_members_grps = [for grps in var.group_name : "group:${grps}"]
  authoritative_members      = local.authoritative ? concat(local.authoritative_members_sa, local.authoritative_members_grps) : []

  # BIGQUERY
  bq_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "BIGQUERY" } : {}
  bq_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "BIGQUERY" } : {}
  bq_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "BIGQUERY" } : {}

  # BIGTABLE
  bt_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "BIGTABLE" } : {}
  bt_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "BIGTABLE" } : {}
  bt_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "BIGTABLE" } : {}

  # DATAPROC
  dp_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "DATAPROC" } : {}
  dp_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "DATAPROC" } : {}
  dp_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "DATAPROC" } : {}

  # DATAFLOW
  df_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "DATAFLOW" } : {}
  df_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "DATAFLOW" } : {}
  df_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "DATAFLOW" } : {}

  # GCS
  gcs_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "GCS" } : {}
  gcs_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "GCS" } : {}
  gcs_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "GCS" } : {}

  # PUBSUB_SUBS
  pbs_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "PUBSUB_SUBS" } : {}
  pbs_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "PUBSUB_SUBS" } : {}
  pbs_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "PUBSUB_SUBS" } : {}

  # PUBSUB_TOPIC
  pbt_sa_permissions       = local.non_authoritative ? { for perms in local.acc_service_account : "${perms.permission}-${perms.resource}-${perms.service_account}" => perms if perms.resource == "PUBSUB_TOPIC" } : {}
  pbt_grps_permissions     = local.non_authoritative ? { for perms in local.acc_groups : "${perms.permission}-${perms.resource}-${perms.group}" => perms if perms.resource == "PUBSUB_TOPIC" } : {}
  pbt_authoritative_access = local.authoritative ? { for perms in var.access : "${perms.permission}-${perms.resource}-${perms.subcomponent}" => perms if perms.resource == "PUBSUB_TOPIC" } : {}
}
