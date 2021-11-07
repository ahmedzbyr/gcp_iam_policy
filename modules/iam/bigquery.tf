
locals {
  role_mapping = {
    "ADMIN"       = "roles/bigquery.admin"
    "DATA_EDITOR" = "roles/bigquery.dataEditor"
    "DATA_OWNER"  = "roles/bigquery.dataOwner"
  }
}

resource "google_bigquery_dataset_iam_binding" "ba_auth_sa" {
  for_each   = local.bq_authoritative_access
  project    = var.project
  dataset_id = each.value.component
  role       = local.role_mapping[each.value.permission]
  members    = local.authoritative_members

}

resource "google_bigquery_dataset_iam_member" "bq_sa" {
  for_each   = local.bq_sa_permissions
  project    = var.project
  dataset_id = each.value.component
  role       = local.role_mapping[each.value.permission]
  member     = "serviceAccount:${each.value.service_account}"
}

resource "google_bigquery_dataset_iam_member" "bq_grp" {
  for_each   = local.bq_grps_permissions
  project    = var.project
  dataset_id = each.value.component
  role       = local.role_mapping[each.value.permission]
  member     = "group:${each.value.group}"
}