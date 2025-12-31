---
applyTo:
  - "infra/terraform/**/*.tf"
  - "**/*.tf"
  - "**/*.tfvars"
---

# Terraform Instructions

## File Structure

Separate concerns into different files:

- `main.tf` - Main resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `providers.tf` - Provider configuration
- `versions.tf` - Terraform and provider version constraints
- `locals.tf` - Local values (optional)

## Naming Conventions

- Resources: lowercase with underscores (e.g., `resource_group_main`)
- Variables: lowercase with underscores (e.g., `resource_group_name`)
- Use descriptive names
- Prefix related resources (e.g., `app_service`, `app_service_plan`)

```hcl
# Good
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location}"
  location = var.location
}

# Bad
resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "eastus"
}
```

## Variables

Always include descriptions and use validation:

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

## Modules

Create reusable modules:

```hcl
# modules/app/main.tf
resource "azurerm_app_service_plan" "main" {
  name                = "asp-${var.app_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

resource "azurerm_app_service" "main" {
  name                = "app-${var.app_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.main.id
}

# Use module
module "app" {
  source = "../../modules/app"
  
  app_name            = "budgetbuddy"
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku_tier            = "Standard"
  sku_size            = "S1"
}
```

## Outputs

Make outputs useful:

```hcl
output "app_url" {
  description = "URL of the deployed application"
  value       = "https://${azurerm_app_service.main.default_site_hostname}"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  sensitive   = false
}
```

## State Management

- Use remote state for shared environments
- Use state locking
- Never commit state files
- Use workspaces or separate directories for environments

```hcl
# Configure remote state (Azure Storage)
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatebudgetbuddy"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

## Secrets

Never hardcode secrets:

```hcl
# Bad
resource "azurerm_mssql_server" "main" {
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd123!"  # NEVER DO THIS
}

# Good - use variable with sensitive = true
variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

resource "azurerm_mssql_server" "main" {
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
}

# Even better - use Azure Key Vault
data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = var.key_vault_id
}

resource "azurerm_mssql_server" "main" {
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value
}
```

## Tagging

Always tag resources:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "BudgetBuddy"
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-budgetbuddy-${var.environment}"
  location = var.location
  tags     = local.common_tags
}
```

## Dependencies

Use explicit dependencies when needed:

```hcl
resource "azurerm_app_service" "main" {
  # ...
  
  depends_on = [
    azurerm_mssql_database.main,
    azurerm_app_service_plan.main
  ]
}
```

## Lifecycle

Use lifecycle blocks appropriately:

```hcl
resource "azurerm_storage_account" "main" {
  name                     = "stbudgetbuddy${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags["CreatedDate"]
    ]
  }
}
```

## Formatting

Always run terraform fmt:

```bash
terraform fmt -recursive
```

Use consistent formatting:
- 2 spaces for indentation
- Align equals signs in blocks
- Order resource arguments logically

## Testing

Validate before applying:

```bash
terraform init
terraform validate
terraform fmt -check
terraform plan
```

Use `terraform plan -out=tfplan` to review before applying.
