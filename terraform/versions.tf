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
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstateaccount"
    # container_name       = "tfstate"
    # key                  = "budgetbuddy.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
