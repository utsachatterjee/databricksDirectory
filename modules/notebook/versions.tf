terraform {
  required_version = ">= 1.2"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.23.0, < 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}

provider "databricks" {
  host = var.databricks_workspace_url
}