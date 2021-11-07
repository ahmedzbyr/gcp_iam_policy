# Min permission at project level mappings.
locals {
  min_roles = {
    "BIGQUERY" = "roles/bigquery.user"
    "DATAPROC" = "roles/dataproc.worker"
    "DATAFLOW" = "roles/dataflow.worker"
    "BIGTABLE" = "roles/bigtable.viewer"
  }
}

# Creating service account if var.create_service_account = true.
resource "google_service_account" "service_account" {
  for_each     = local.service_accounts_to_create
  project      = var.project
  account_id   = each.value.service_account # Account ID to be created
  display_name = "Service Account"
}

# Project level minimum access permission to the service account.
# This permission are only for service account.
resource "google_project_iam_member" "project" {
  for_each = local.project_iam_members_permissions
  project  = var.project
  role     = local.min_roles[each.value.product]            # Min permission mapping 
  member   = "serviceAccount:${each.value.service_account}" # Service account from the list 

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #   when we have to create service account then we wait for it complete.
  ]
}
