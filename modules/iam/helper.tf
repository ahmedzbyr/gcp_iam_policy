locals {

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
  # BIGQUERY
  #
  bq_sa_permissions = {
    for bq_perms in local.acc_service_account : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.service_account}" => bq_perms if bq_perms.product == "BIGQUERY"
  }

  bq_grps_permissions = {
    for bq_perms in local.acc_groups : "${bq_perms.permission}-${bq_perms.product}-${bq_perms.group}" => bq_perms if bq_perms.product == "BIGQUERY"
  }

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