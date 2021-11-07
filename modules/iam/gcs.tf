locals {
  gcs_role_mapping = {
    "ADMIN"          = "roles/storage.admin"
    "OBJECT_ADMIN"   = "roles/storage.objectAdmin"
    "OBJECT_VIEWER"  = "roles/storage.objectViewer"
    "OBJECT_CREATOR" = "roles/storage.objectCreator"
  }
}

resource "google_storage_bucket_iam_binding" "storage_bucket_iam_authoritative" {
  for_each = local.gcs_authoritative_access
  #project  = var.project
  bucket  = each.value.component
  role    = local.gcs_role_mapping[each.value.permission] # Role which is mapped above in local variables
  members = local.authoritative_members                   # Authoritative Permissions on the dataset.

  # dynamic "condition" {
  #   for_each = var.access_conditions == {} ? [] : [var.access_conditions]
  #   content {
  #     title       = each.value.condition.title
  #     description = each.value.condition.description
  #     expression  = each.value.condition.expression
  #   }
  # }

  depends_on = [
    google_service_account.service_account
  ]
}


# Non-authoritative
resource "google_storage_bucket_iam_member" "gcs_sa_iam_non_authoritative" {
  for_each = local.gcs_sa_permissions
  #project  = var.project                                    # Project
  bucket = each.value.component                           # bucket  to give permissions on 
  role   = local.gcs_role_mapping[each.value.permission]  # Role which is mapped above in local variables
  member = "serviceAccount:${each.value.service_account}" # Group permissions on the bucket   

  # dynamic "condition" {
  #   for_each = var.access_conditions == {} ? [] : [var.access_conditions]
  #   content {
  #     title       = each.value.condition.title
  #     description = each.value.condition.description
  #     expression  = each.value.condition.expression
  #   }
  # }

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #   when we have to create service account then we wait for it complete.
  ]
}

resource "google_storage_bucket_iam_member" "gcs_grp_iam_non_authoritative" {
  for_each = local.gcs_grps_permissions
  #project  = var.project                                   # Project
  bucket = each.value.component                          # bucket  to give permissions on 
  role   = local.gcs_role_mapping[each.value.permission] # Role which is mapped above in local variables
  member = "group:${each.value.group}"                   # Group permissions on the bucket   

  # dynamic "condition" {
  #   for_each = var.access_conditions == {} ? [] : [var.access_conditions]
  #   content {
  #     title       = each.value.condition.title
  #     description = each.value.condition.description
  #     expression  = each.value.condition.expression
  #   }
  # }

  depends_on = [                           # We have this dependency just to make sure
    google_service_account.service_account #    when we have to create service account then we wait for it complete.
  ]                                        #    Though this is a group permission we wait anyways.
}
