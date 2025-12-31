# Dev environment configuration
terraform {
  required_version = ">= 1.6.0"
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatebudgetbuddy"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

locals {
  environment = "dev"
  location    = "eastus"
  
  common_tags = {
    Environment = local.environment
    Project     = "BudgetBuddy"
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-budgetbuddy-${local.environment}-${local.location}"
  location = local.location
  tags     = local.common_tags
}

# Placeholder for modules
# Uncomment and configure when modules are created

# module "networking" {
#   source = "../../modules/networking"
#   
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   
#   tags = local.common_tags
# }

# module "data" {
#   source = "../../modules/data"
#   
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   
#   tags = local.common_tags
# }

# module "app" {
#   source = "../../modules/app"
#   
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   
#   tags = local.common_tags
# }

# module "observability" {
#   source = "../../modules/observability"
#   
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   
#   tags = local.common_tags
# }
