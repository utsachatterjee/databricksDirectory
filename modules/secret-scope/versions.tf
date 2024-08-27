terraform {
  required_version = ">= 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.11, < 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.23.0, < 2.0"
      #version = "1.0.0"
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
