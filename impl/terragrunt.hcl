# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))


  # Azure locals
  # Extract the variables we need for easy access
  application                            = local.environment_vars.locals.application_name
  deployment_storage_resource_group_name = local.environment_vars.locals.deployment_storage_resource_group_name
  deployment_storage_account_name        = local.environment_vars.locals.deployment_storage_account_name
  deployment_storage_container_name      = local.environment_vars.locals.deployment_storage_container_name
  git_branch                             = local.environment_vars.locals.git_branch
  env                                    = local.environment_vars.locals.environment
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an Blob Storage container
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    //subscription_id      = local.subscription_id
    resource_group_name  = local.deployment_storage_resource_group_name
    storage_account_name = local.deployment_storage_account_name
    container_name       = local.deployment_storage_container_name
    key                  = "${local.application}/databricks-job/${local.git_branch}/${path_relative_to_include()}/terraform.tfstate"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
  {
    tags = {
      application      = local.application
      environment      = local.env
      created-date     = "04292024"
      created-by       = "terraform"
      chargeback-code  = "575341"
      contact-info     = "dna_cloud_infrastructure@wcgclinical.com"
      customer         = "wcg"
      business-segment = "data services"
      resource-owner   = "dna_cloud_infrastructure@wcgclinical.com"
      git_branch       = local.git_branch
    }
  }
)
