# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {

  application_name                       = "data-services"
  application                            = "ds"
  customer                               = "wcg"
  environment                            = "prd"
  rev                                    = "00"
  base_name                              = "${local.application}-${local.customer}-${local.environment}-${local.rev}"
  tight_base_name                        = "${local.application}${local.customer}${local.environment}${local.rev}"
  deployment_storage_resource_group_name = "rg-data-services01-devsecops-${local.environment}"
  deployment_storage_account_name        = "sadataservices01${local.environment}"
  deployment_storage_container_name      = "data-services01-tfstate"
  git_branch_tmp                         = run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD")
  git_branch                             = local.git_branch_tmp == "HEAD" ? get_env("BRANCH_NAME") : local.git_branch_tmp
  databricks_workspace_url               = "https://adb-1692951720151401.1.azuredatabricks.net/"
  databricks_warehouse_id                = "6a4e93f9399b958e"

  job_cluster_key            = "new_cluster"
  cluster_spark_version      = "14.3.x-scala2.12"
  cluster_node_type_id       = "Standard_E4d_v4"
  cluster_runtime_engine     = "STANDARD"
  cluster_data_security_mode = "USER_ISOLATION"
  cluster_num_workers        = 4
  instance_pool_id           = "0326-200503-legal93-pool-4ra4xw2q"

  cost_analysis_job_pause_status = "UNPAUSED"

  databricks_secret_scope_name = {
    ss1 = {
      name                      = "ss-${local.base_name}"
      permission_read_required  = false
      permission_write_required = true
      WRITE                     = ["GRP_data_services_deployments_${lower(local.environment)}"]
    }
  }
  databricks_workspace_repo = {

    dbkjobs = {
      url        = "https://bitbucket.org/wcgclinical/data-services-databricks-job-iac.git"
      path       = "/Repos/data-services/data-services-databricks-job-iac"
      branch     = get_env("BRANCH_NAME", "develop")
      CAN_MANAGE = ["GRP_DBx_data_services_developers_${lower(local.environment)}"]
      CAN_READ   = ["GRP_DBx_data_services_readers_${lower(local.environment)}"]
    }
  }

}
