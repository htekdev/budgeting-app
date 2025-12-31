# Terraform Infrastructure for BudgetBuddy

This directory contains Infrastructure as Code (IaC) using Terraform to deploy BudgetBuddy to Azure.

## Structure

```
terraform/
├── modules/           # Reusable Terraform modules
│   ├── app/          # Application hosting (Container Apps)
│   ├── data/         # Database (Azure SQL)
│   ├── networking/   # Virtual Network, subnets, NSGs
│   └── observability/# Log Analytics, Application Insights
├── envs/             # Environment-specific configurations
│   ├── dev/          # Development environment
│   └── prod/         # Production environment
├── main.tf           # Root module (if using)
├── variables.tf      # Common variables
├── outputs.tf        # Common outputs
├── providers.tf      # Provider configuration
└── versions.tf       # Terraform and provider versions
```

## Prerequisites

1. **Azure CLI**: Install and configure
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

2. **Terraform**: Install Terraform >= 1.6.0
   ```bash
   terraform version
   ```

3. **Required Azure Permissions**:
   - Contributor access to subscription or resource group
   - Ability to create service principals (for remote state)

## Quick Start

### Development Environment

```bash
cd envs/dev

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Production Environment

```bash
cd envs/prod

# Initialize Terraform
terraform init

# Plan changes (review carefully!)
terraform plan -out=tfplan

# Apply approved plan
terraform apply tfplan
```

## Remote State

The state is stored in Azure Storage to enable collaboration and prevent conflicts.

### Setup Remote State

1. Create storage account:
   ```bash
   # Create resource group for state
   az group create --name rg-terraform-state --location eastus
   
   # Create storage account
   az storage account create \
     --name sttfstatebudgetbuddy \
     --resource-group rg-terraform-state \
     --location eastus \
     --sku Standard_LRS \
     --encryption-services blob
   
   # Create container
   az storage container create \
     --name tfstate \
     --account-name sttfstatebudgetbuddy
   ```

2. Configure backend in `envs/dev/main.tf`:
   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "rg-terraform-state"
       storage_account_name = "sttfstatebudgetbuddy"
       container_name       = "tfstate"
       key                  = "dev.terraform.tfstate"
     }
   }
   ```

## Environment Variables

Set these environment variables or use Azure CLI authentication:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"        # For service principal
export ARM_CLIENT_SECRET="your-client-secret" # For service principal
```

## Modules

### App Module

Deploys Azure Container Apps for frontend and backend.

```hcl
module "app" {
  source = "../../modules/app"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  # Container images
  backend_image  = "budgetbuddy-api:latest"
  frontend_image = "budgetbuddy-web:latest"
  
  # Configuration
  connection_string = module.data.sql_connection_string
  
  tags = local.common_tags
}
```

### Data Module

Deploys Azure SQL Database.

```hcl
module "data" {
  source = "../../modules/data"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  sql_admin_username = "sqladmin"
  sql_admin_password = var.sql_admin_password  # From Key Vault or secure variable
  
  tags = local.common_tags
}
```

### Networking Module

Sets up Virtual Network and subnets.

```hcl
module "networking" {
  source = "../../modules/networking"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  vnet_address_space = ["10.0.0.0/16"]
  
  tags = local.common_tags
}
```

### Observability Module

Configures Log Analytics and Application Insights.

```hcl
module "observability" {
  source = "../../modules/observability"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = local.common_tags
}
```

## Environments

### Development (dev)

- Lower SKUs for cost savings
- No geo-redundancy
- Relaxed network rules
- Auto-delete after hours (optional)

### Production (prod)

- Production-grade SKUs
- Geo-redundancy enabled
- Strict network rules
- Backup and disaster recovery
- High availability

## Common Commands

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources in state
terraform state list

# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME

# Destroy environment (careful!)
terraform destroy
```

## Best Practices

1. **Never commit secrets**: Use Azure Key Vault or environment variables
2. **Always run plan first**: Review changes before applying
3. **Use remote state**: Enable collaboration and prevent conflicts
4. **Tag everything**: Helps with cost management and organization
5. **Use modules**: DRY principle, reusable components
6. **Version control**: Commit terraform files, not state files
7. **Peer review**: Always have someone review infrastructure changes

## Cost Estimation

Use `terraform plan` with cost estimation tools:

```bash
# Install Infracost
brew install infracost  # macOS
# or
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Get cost estimate
infracost breakdown --path .
```

## Troubleshooting

### State Lock Issues

If state is locked:
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### Provider Authentication Issues

```bash
# Verify Azure CLI login
az account show

# Re-login if needed
az login
```

### Module Source Issues

```bash
# Clean module cache
rm -rf .terraform/modules

# Re-initialize
terraform init -upgrade
```

## CI/CD Integration

See `.github/workflows/terraform.yml` for automated validation and deployment.

Pipeline runs:
1. `terraform fmt -check` - Verify formatting
2. `terraform init` - Initialize
3. `terraform validate` - Validate configuration
4. `terraform plan` - Plan changes (on PR)
5. `terraform apply` - Apply changes (on merge to main)

## Security

- Secrets stored in Azure Key Vault
- Managed identities where possible
- Network security groups configured
- TLS/SSL enforced
- Regular security scanning with Checkov/tfsec

## Support

For issues or questions:
- Check this README
- Review module documentation
- Check GitHub Issues
- Consult Azure documentation
