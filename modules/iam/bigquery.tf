
# Dataset permission mappings, this could be custom roles as well.
locals {
  bq_role_mapping = {
    "ADMIN"       = "roles/bigquery.admin"
    "DATA_EDITOR" = "roles/bigquery.dataEditor"
    "DATA_OWNER"  = "roles/bigquery.dataOwner"
  }
}

#
# mode_authoritative  = true;  "Authoritative" means to change all related privileges for the specific role, (Authoritative: Single source of truth for a given role)
# mode_authoritative  = false; "Non-authoritative" means not to change related privileges, only to change ones you specified. (Additive : Adding permissions to already exsiting policy)
#
#   authoritative as the single source of truth for a specific role (other roles which are not specified in the access list are preserved), and 
#   non-authoritative (additive) is added to existing policies.
#

# Authoritative
resource "google_bigquery_dataset_iam_binding" "bq_auth_sa" {
  for_each   = local.bq_authoritative_access
  project    = var.project
  dataset_id = each.value.component
  role       = local.bq_role_mapping[each.value.permission] # Role which is mapped above in local variables
  members    = local.authoritative_members                  # Authoritative Permissions on the dataset.
  depends_on = [
    google_service_account.service_account
  ]
}

# Non-authoritative
resource "google_bigquery_dataset_iam_member" "bq_sa" {
  for_each   = local.bq_sa_permissions
  project    = var.project                                    # Project
  dataset_id = each.value.component                           # dataset to give permissions on 
  role       = local.bq_role_mapping[each.value.permission]   # Role which is mapped above in local variables
  member     = "serviceAccount:${each.value.service_account}" # Group permissions on the dataset 

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #   when we have to create service account then we wait for it complete.
  ]
}

resource "google_bigquery_dataset_iam_member" "bq_grp" {
  for_each   = local.bq_grps_permissions
  project    = var.project                                  # Project
  dataset_id = each.value.component                         # dataset to give permissions on 
  role       = local.bq_role_mapping[each.value.permission] # Role which is mapped above in local variables
  member     = "group:${each.value.group}"                  # Group permissions on the dataset 

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #    when we have to create service account then we wait for it complete.
  ]                                        #    Though this is a group permission we wait anyways.
}
