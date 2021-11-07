
# Dataset permission mappings, this could be custom roles as well.
locals {
  bt_role_mapping = {
    "ADMIN"  = "roles/bigtable.admin"
    "USER"   = "roles/bigtable.user"
    "READER" = "roles/bigtable.reader"
    "VIEWER" = "roles/bigtable.viewer"
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
resource "google_bigtable_instance_iam_binding" "bt_iam_authoritative" {
  for_each = local.bt_authoritative_access
  project  = var.project
  instance = each.value.component
  role     = local.bt_role_mapping[each.value.permission] # Role which is mapped above in local variables
  members  = local.authoritative_members                  # Authoritative Permissions on the dataset.
  depends_on = [
    google_service_account.service_account
  ]
}

# Non-authoritative
resource "google_bigtable_instance_iam_member" "bt_sa_iam_non_authoritative" {
  for_each = local.bt_sa_permissions
  project  = var.project                                    # Project
  instance = each.value.component                           # instance to give permissions on 
  role     = local.bt_role_mapping[each.value.permission]   # Role which is mapped above in local variables
  member   = "serviceAccount:${each.value.service_account}" # Group permissions on the instance  

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #   when we have to create service account then we wait for it complete.
  ]
}

resource "google_bigtable_instance_iam_member" "bt_grp_iam_non_authoritative" {
  for_each = local.bt_grps_permissions
  project  = var.project                                  # Project
  instance = each.value.component                         # instance to give permissions on 
  role     = local.bt_role_mapping[each.value.permission] # Role which is mapped above in local variables
  member   = "group:${each.value.group}"                  # Group permissions on the instance  

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #    when we have to create service account then we wait for it complete.
  ]                                        #    Though this is a group permission we wait anyways.
}
