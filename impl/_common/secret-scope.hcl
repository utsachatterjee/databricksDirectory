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
  source = "${get_path_to_repo_root()}/modules/secret-scope"
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
}

# ---------------------------------------------------------------------------------------------------------------------
# dependencies
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# The below can be removed if you set vnet_needed to false in an env.hcl
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  env                          = local.env
  databricks_secret_scope_name = local.environment_vars.locals.databricks_secret_scope_name
  databricks_workspace_url     = local.environment_vars.locals.databricks_workspace_url
}
