locals {
  min_roles = {
    "BIGQUERY" = "roles/bigquery.user"
    "DATAPROC" = "roles/dataproc.worker"
    "DATAFLOW" = "roles/dataflow.worker"
    "BIGTABLE" = "roles/bigtable.viewer"
  }
}

resource "google_service_account" "service_account" {
  for_each     = local.service_accounts_to_create
  project      = var.project
  account_id   = each.value.service_account
  display_name = "Service Account"
}

resource "google_project_iam_member" "project" {
  for_each = local.project_iam_members_permissions
  project  = var.project
  role     = local.min_roles[each.value.product]
  member   = "serviceAccount:${each.value.service_account}"
  depends_on = [
    google_service_account.service_account
  ]
}