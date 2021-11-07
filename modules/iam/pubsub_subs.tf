
# Dataset permission mappings, this could be custom roles as well.
locals {
  pbs_role_mapping = {
    "SUBSCRIBER" = "roles/pubsub.subscriber"
    "EDITOR"     = "roles/pubsub.editor"
    "ADMIN"      = "roles/pubsub.admin"
    "VIEWER"     = "roles/pubsub.viewer"
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
resource "google_pubsub_subscription_iam_binding" "pbs_iam_authoritative" {
  for_each     = local.pbs_authoritative_access
  project      = var.project
  subscription = each.value.component
  role         = local.pbs_role_mapping[each.value.permission] # Role which is mapped above in local variables
  members      = local.authoritative_members                   # Authoritative Permissions on the dataset.
  depends_on = [
    google_service_account.service_account
  ]
}

# Non-authoritative
resource "google_pubsub_subscription_iam_member" "pbs_sa_iam_non_authoritative" {
  for_each     = local.pbs_sa_permissions
  project      = var.project                                    # Project
  subscription = each.value.component                           # subscription  to give permissions on 
  role         = local.pbs_role_mapping[each.value.permission]  # Role which is mapped above in local variables
  member       = "serviceAccount:${each.value.service_account}" # Group permissions on the subscription   

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #   when we have to create service account then we wait for it complete.
  ]
}

resource "google_pubsub_subscription_iam_member" "pbs_grp_iam_non_authoritative" {
  for_each     = local.pbs_grps_permissions
  project      = var.project                                   # Project
  subscription = each.value.component                          # subscription  to give permissions on 
  role         = local.pbs_role_mapping[each.value.permission] # Role which is mapped above in local variables
  member       = "group:${each.value.group}"                   # Group permissions on the subscription   

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #    when we have to create service account then we wait for it complete.
  ]                                        #    Though this is a group permission we wait anyways.
}
