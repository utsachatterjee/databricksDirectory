# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${get_path_to_repo_root()}/modules/jobs"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  application = local.environment_vars.locals.application
  region      = local.region_vars.locals.region
  databricks_jobs = {

    cost_analysis = {
      name        = "dbx_cost_analysis_report"
      description = "Workflow to analyize and report databricks services cost"
      job_tasks = {
        cost_analysis_task = {
          task_type = "notebook_task"
          task_specific_properties = {
            notebook_path = "/Workspace/Repos/utsa/workspace/costAnalysis/cost_analysis_query"
          }
          base_parameters = {
            "env" = local.environment_vars.locals.environment
          }
        }
      }
      job_schedules = [
        {
          quartz_cron_expression = "0 0 6 ? * FRI *"
          timezone_id            = "UTC"
          pause_status           = local.environment_vars.locals.cost_analysis_job_pause_status
        }
      ]
      CAN_MANAGE_RUN = ["grp1"]
      CAN_VIEW       = ["grp2"]
    }
    copy_sc_dc = {
      name        = "copy_sc_deep_clone"
      description = "Workflow to copy data from shared catalogs to the corresponding regular catalogs."
      job_tasks = {
        copy_sc_deep_clone = {
          task_type = "notebook_task",
          task_specific_properties = {
            notebook_path = "/Repos/utsa/workspace/deltaShare/copy_sc_deep_clone"
          }
          base_parameters = {
            "source_catalog" = "default_value",
            "target_catalog" = "default_value"
          }
        }
      }
      CAN_MANAGE = ["grp1"]
      CAN_VIEW   = ["grp2"]
    }

    copy_fc_dc_catalog = {
      name        = "copy_fc_deep_clone"
      description = "Workflow to copy data from foriegn catalogs to the corresponding regular catalogs."
      cluster_config = {
        cl1 = {
          clusterkey         = local.environment_vars.locals.job_cluster_key
          nodetype           = local.environment_vars.locals.cluster_node_type_id
          num_workers        = local.environment_vars.locals.cluster_num_workers
          data_security_mode = local.environment_vars.locals.cluster_data_security_mode
          spark_version      = local.environment_vars.locals.cluster_spark_version
          instance_pool_id   = local.environment_vars.locals.instance_pool_id
        }
      }
      job_tasks = {
        copy_fc_deep_clone = {
          task_type = "notebook_task",
          task_specific_properties = {
            notebook_path = "/Repos/utsa/workspace/deltaShare/copy_fc_deep_clone"
          }
          base_parameters = {
            "source_catalog" = "`${lower(local.env)}_aims4-fs`",
            "target_catalog" = "`${lower(local.env)}_clinsphere-aims4`"
          }
        }
      }
      CAN_MANAGE = ["grp1"]
      CAN_VIEW   = ["grp2"]
    }
    copy_kmr_usertable = {
      name        = "copy_usertable"
      description = "Workflow to copy data from foriegn catalogs to the corresponding regular catalogs."
      cluster_config = {
        cl1 = {
          clusterkey         = local.environment_vars.locals.job_cluster_key
          nodetype           = local.environment_vars.locals.cluster_node_type_id
          num_workers        = local.environment_vars.locals.cluster_num_workers
          data_security_mode = local.environment_vars.locals.cluster_data_security_mode
          spark_version      = local.environment_vars.locals.cluster_spark_version
          instance_pool_id   = local.environment_vars.locals.instance_pool_id
        }
      }
      job_tasks = {
        copy_kmr_usertable = {
          task_type = "notebook_task",
          task_specific_properties = {
            notebook_path = "/Repos/utsa/workspace/deltaShare/copy_usertable"
          }
          base_parameters = {
          }
        }
      }
      CAN_MANAGE = ["grp1"]
      CAN_VIEW   = ["grp2"]
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# dependencies
# ---------------------------------------------------------------------------------------------------------------------
dependencies {
  paths = ["../repo"]
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# The below can be removed if you set vnet_needed to false in an env.hcl
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  databricks_workspace_url = local.environment_vars.locals.databricks_workspace_url
  databricks_jobs          = local.databricks_jobs
}


