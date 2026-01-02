# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "budgetbuddy-${var.environment}-rg"
  location = var.location
  tags     = merge(var.tags, { Environment = var.environment })
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "budgetbuddy-${var.environment}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = merge(var.tags, { Environment = var.environment })
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "budgetbuddy-${var.environment}-api"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = merge(var.tags, { Environment = var.environment, Component = "Backend" })

  site_config {
    always_on         = var.environment == "prod" ? true : false
    health_check_path = "/health"
    
    application_stack {
      dotnet_version = "10.0"
    }

    cors {
      allowed_origins = [
        "https://budgetbuddy-${var.environment}-web.azurewebsites.net"
      ]
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = var.environment == "prod" ? "Production" : "Development"
    "ConnectionStrings__DefaultConnection" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_connection_string.id})"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Frontend App Service (Static Web App alternative)
resource "azurerm_linux_web_app" "frontend" {
  name                = "budgetbuddy-${var.environment}-web"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = merge(var.tags, { Environment = var.environment, Component = "Frontend" })

  site_config {
    always_on = var.environment == "prod" ? true : false
    
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    "VITE_API_URL" = "https://${azurerm_linux_web_app.backend.default_hostname}"
    "NODE_ENV"     = var.environment == "prod" ? "production" : "development"
  }
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "budgetbuddy-${var.environment}-sql"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  tags                         = merge(var.tags, { Environment = var.environment })

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = azurerm_linux_web_app.backend.identity[0].principal_id
  }
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "BudgetBuddyDB"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = var.sql_database_sku
  zone_redundant = false
  tags           = merge(var.tags, { Environment = var.environment })
}

# SQL Firewall Rule - Allow Azure Services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# SQL Firewall Rules - Allow specific IPs
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  for_each = toset(var.allowed_ip_addresses)
  
  name             = "AllowIP-${replace(each.value, ".", "-")}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                       = "budgetbuddy-${var.environment}-kv"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = var.environment == "prod" ? true : false
  tags                       = merge(var.tags, { Environment = var.environment })

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_web_app.backend.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }
}

# Key Vault Secret - SQL Connection String
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "SqlConnectionString"
  value        = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;"
  key_vault_id = azurerm_key_vault.main.id
  tags         = merge(var.tags, { Environment = var.environment })
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "budgetbuddy-${var.environment}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = merge(var.tags, { Environment = var.environment })
}

# Data source for current Azure client config
data "azurerm_client_config" "current" {}
