# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.

locals {

  application_name                       = "databricks"
  application                            = "dbk"
  environment                            = "sbx"
  rev                                    = "00"
  base_name                              = "${local.application}-${local.customer}-${local.environment}-${local.rev}"
  tight_base_name                        = "${local.application}${local.customer}${local.environment}${local.rev}"
  deployment_storage_resource_group_name = ""
  deployment_storage_account_name        = ""
  deployment_storage_container_name      = ""
  git_branch                             = local.git_branch_tmp == "HEAD" ? get_env("BRANCH_NAME") : local.git_branch_tmp

  databricks_workspace_url = ""
  databricks_warehouse_id  = ""

  # Workflow cluster Config details Global Data
  job_cluster_key            = "new_cluster"
  cluster_spark_version      = "14.3.x-scala2.12"
  cluster_node_type_id       = "Standard_DS3_v2"
  cluster_runtime_engine     = "STANDARD"
  cluster_data_security_mode = "SINGLE_USER"
  cluster_num_workers        = 1
  instance_pool_id           = ""

  cost_analysis_job_pause_status = "PAUSED"

  databricks_secret_scope_name = {
    ss1 = {
      name                      = "ss-${local.base_name}"
      permission_read_required  = false
      permission_write_required = true
      WRITE                     = ["Grp1", "Grp2"]
    }
  }


  databricks_workspace_repo = {
    dbkjobs = {
      url        = "URL"
      path       = "/Repos/utsa"
      branch     = get_env("BRANCH_NAME", "feature/sandbox")
      CAN_MANAGE = ["grp1"]
      CAN_READ   = ["grp2"]
    }
  }
}
