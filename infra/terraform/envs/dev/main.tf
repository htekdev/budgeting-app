# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Data Module (SQL Server)
module "data" {
  source = "../../modules/data"

  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  project_name        = var.project_name
  sql_admin_password  = var.sql_admin_password
  tags                = var.tags
}

# App Module (Container Apps or App Service)
module "app" {
  source = "../../modules/app"

  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  project_name        = var.project_name
  sql_connection_string = module.data.sql_connection_string
  tags                = var.tags
}

# Observability Module (Log Analytics, App Insights)
module "observability" {
  source = "../../modules/observability"

  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  project_name        = var.project_name
  tags                = var.tags
}
