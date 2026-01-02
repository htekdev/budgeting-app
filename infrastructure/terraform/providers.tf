terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    # Backend configuration should be provided via backend config file or CLI
    # Example:
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstate<uniqueid>"
    # container_name       = "tfstate"
    # key                  = "budgetbuddy.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
