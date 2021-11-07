locals {
  service_account        = ["bq-backups@driven-lore-328513.iam.gserviceaccount.com"]
  group_name             = ["my_grp@google.com"]
  create_service_account = false

  #
  # mode_authoritative  = true;  "Authoritative" means to change all related privileges for the specific role, (Authoritative: Single source of truth for a given role)
  # mode_authoritative  = false; "non-authoritative" means not to change related privileges, only to change ones you specified. (Additive : Adding permissions to already exsiting policy)
  #
  #   authoritative as the single source of truth for a specific role (other roles which are not specified in the access list are preserved), and 
  #   non-authoritative (additive) is added to existing policies.
  #
  mode_authoritative = false

  access = [
    {
      product    = "BIGQUERY"
      component  = "test_dataset_id"
      permission = "ADMIN"
    }
  ]
}

module "setup_iam_policy" {
  source                 = "../../modules/iam"
  project                = "driven-lore-328513"
  service_account        = local.service_account
  group_name             = local.group_name
  create_service_account = local.create_service_account
  access                 = local.access # Access permission to each component in GCP
}

