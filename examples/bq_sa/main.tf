module "setup_iam_policy_basic" {
  source          = "../../modules/iam"
  project         = "driven-lore-328513"
  service_account = ["bq-backups-basic@driven-lore-328513.iam.gserviceaccount.com"]
  access = [
    {
      product    = "BIGQUERY"
      component  = "test_dataset_id"
      permission = "ADMIN"
    }
  ]
}

module "setup_iam_policy_all" {
  source                 = "../../modules/iam"
  project                = "driven-lore-328513"
  service_account        = ["bq-backups-all@driven-lore-328513.iam.gserviceaccount.com"]
  create_service_account = true
  group_name             = ["my_grp@google.com"]
  mode_authoritative     = true
  access = [
    {
      product    = "BIGQUERY"
      component  = "test_dataset_id"
      permission = "ADMIN"
    }
  ]
}

module "setup_iam_policy_mixed" {
  source                 = "../../modules/iam"
  project                = "driven-lore-328513"
  service_account        = ["bq-backups-mix@driven-lore-328513.iam.gserviceaccount.com"]
  create_service_account = true
  group_name             = ["my_grp@google.com"]
  mode_authoritative     = false
  access = [
    {
      product    = "BIGQUERY"
      component  = "test_dataset_id"
      permission = "ADMIN"
    }
  ]
}
