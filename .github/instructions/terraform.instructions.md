---
applyTo:
  - 'infrastructure/**/*.tf'
---

# Terraform Infrastructure Instructions

## Terraform Best Practices
- Use meaningful resource names following Azure naming conventions
- Use variables for all configurable values
- Add descriptions to all variables and outputs
- Tag all resources consistently
- Use remote state storage (Azure Storage)
- Pin provider versions

## Resource Naming Convention
Follow this pattern: `{resource-type}-{app-name}-{environment}`
- Example: `rg-budgetbuddy-dev`, `app-budgetbuddy-backend-prod`

## Security
- Never commit secrets or passwords
- Use Azure Key Vault for sensitive values
- Implement network security groups
- Enable Azure AD authentication
- Use managed identities where possible

## Organization
- Keep related resources in the same file
- Use separate files for: providers, variables, outputs, main resources
- Group resources logically
- Use modules for reusable infrastructure

## State Management
- Always use remote state for team collaboration
- Lock state during operations
- Back up state regularly
- Never commit state files to Git

## Documentation
- Add comments for complex resource configurations
- Keep README.md updated
- Document all required variables
- Include deployment instructions

## Example Resource
```hcl
resource "azurerm_linux_web_app" "example" {
  name                = "app-${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = var.tags

  site_config {
    application_stack {
      dotnet_version = "10.0"
    }
    always_on = var.environment == "prod"
  }

  identity {
    type = "SystemAssigned"
  }
}
```
