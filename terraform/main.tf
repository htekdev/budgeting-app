# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, { Environment = var.environment })
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.resource_group_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
  tags                = merge(var.tags, { Environment = var.environment })
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "${var.resource_group_name}-backend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = merge(var.tags, { Environment = var.environment, Component = "Backend" })

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "10.0"
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = var.environment
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

# Frontend App Service (Static Web App alternative)
resource "azurerm_linux_web_app" "frontend" {
  name                = "${var.resource_group_name}-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = merge(var.tags, { Environment = var.environment, Component = "Frontend" })

  site_config {
    always_on = false
  }

  app_settings = {
    "VITE_API_URL" = "https://${azurerm_linux_web_app.backend.default_hostname}/api"
  }
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.resource_group_name}-sqlserver"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = merge(var.tags, { Environment = var.environment })
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name      = "BudgetBuddyDb"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "Basic"
  tags      = merge(var.tags, { Environment = var.environment })
}

# SQL Firewall Rule - Allow Azure Services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
