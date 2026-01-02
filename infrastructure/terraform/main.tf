resource "azurerm_resource_group" "main" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "app-${var.app_name}-backend-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = var.tags

  site_config {
    application_stack {
      dotnet_version = "10.0"
    }
    always_on = false
    health_check_path = "/health"
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = var.environment
    "ConnectionStrings__DefaultConnection" = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Frontend App Service  
resource "azurerm_linux_web_app" "frontend" {
  name                = "app-${var.app_name}-frontend-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = var.tags

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = false
  }

  app_settings = {
    "VITE_API_URL" = "https://${azurerm_linux_web_app.backend.default_hostname}/api"
  }
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "sql-${var.app_name}-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = var.tags

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = azurerm_linux_web_app.backend.identity[0].principal_id
  }
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "sqldb-${var.app_name}-${var.environment}"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"
  max_size_gb    = 2
  tags           = var.tags
}

# Firewall rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
  tags                = var.tags
}
