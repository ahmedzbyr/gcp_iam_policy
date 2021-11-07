locals {

  authoritative     = var.mode_authoritative == true
  non_authoritative = var.mode_authoritative == false

  acc_service_account = flatten([
    for access_items in var.access : [
      for sa in var.service_account : merge(access_items, var.access_conditions, { service_account = sa })
    ]
  ])

  acc_groups = flatten([
    for access_items in var.access : [
      for grps in var.group_name : merge(access_items, var.access_conditions, { group = grps })
    ]
  ])

  #
  # Getting  authoritative_members ready if the mode_authoritative is set to true
  #
  authoritative_members_sa   = [for sa in var.service_account : "serviceAccount:${sa}"]
  authoritative_members_grps = [for grps in var.group_name : "group:${grps}"]
  authoritative_members      = local.authoritative ? concat(local.authoritative_members_sa, local.authoritative_members_grps) : []



  #
  # BIGQUERY
  #
  bq_sa_permissions       = local.non_authoritative ? { for bq_perms in local.acc_service_account : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.service_account}" => bq_perms if bq_perms.product == "BIGQUERY" } : {}
  bq_grps_permissions     = local.non_authoritative ? { for bq_perms in local.acc_groups : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.group}" => bq_perms if bq_perms.product == "BIGQUERY" } : {}
  bq_authoritative_access = local.authoritative ? { for bq_perms in var.access : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.component}" => bq_perms if bq_perms.product == "BIGQUERY" } : {}

  #
  # BIGTABLE
  #
  bt_sa_permissions       = local.non_authoritative ? { for bt_perms in local.acc_service_account : "${bt_perms.permission}-${bt_perms.product}-${bt_perms.service_account}" => bt_perms if bt_perms.product == "BIGTABLE" } : {}
  bt_grps_permissions     = local.non_authoritative ? { for bt_perms in local.acc_groups : "${bt_perms.permission}-${bt_perms.product}-${bt_perms.group}" => bt_perms if bt_perms.product == "BIGTABLE" } : {}
  bt_authoritative_access = local.authoritative ? { for bt_perms in var.access : "${bt_perms.permission}-${bt_perms.product}-${bt_perms.component}" => bt_perms if bt_perms.product == "BIGQUERY" } : {}

}