# Terraform Infrastructure for BudgetBuddy

This directory contains Terraform configurations for deploying BudgetBuddy to Azure.

## Structure

- `modules/` - Reusable Terraform modules
  - `app/` - Application hosting (Container Apps)
  - `data/` - Database resources (Azure SQL)
  - `networking/` - Network resources (VNet, subnets)
  - `observability/` - Monitoring (Log Analytics, App Insights)
- `envs/` - Environment-specific configurations
  - `dev/` - Development environment
  - `prod/` - Production environment

## Prerequisites

- Azure subscription
- Azure CLI installed and authenticated
- Terraform >= 1.6.0
- Required permissions to create resources

## Quick Start

### 1. Configure Backend (Optional but Recommended)

For production use, configure remote state:

```bash
# Create storage account for Terraform state
az group create --name rg-budgetbuddy-tfstate --location eastus
az storage account create --name stbudgetbuddytfstate --resource-group rg-budgetbuddy-tfstate --location eastus --sku Standard_LRS
az storage container create --name tfstate --account-name stbudgetbuddytfstate

# Update providers.tf with backend configuration
```

### 2. Initialize Terraform

```bash
cd infra/terraform/envs/dev
terraform init
```

### 3. Create Variables File

Create `terraform.tfvars`:

```hcl
environment        = "dev"
location           = "eastus"
project_name       = "budgetbuddy"
sql_admin_password = "YourSecurePassword123!"  # Use secrets in production!

tags = {
  Project     = "BudgetBuddy"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

**⚠️ Important**: Never commit `terraform.tfvars` with real passwords!

### 4. Plan and Apply

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Module Documentation

### App Module

Deploys:
- Azure Container Apps Environment
- Container Apps for frontend and backend
- Container Registry (or reference to existing registry)

### Data Module

Deploys:
- Azure SQL Server
- Azure SQL Database
- Firewall rules

### Observability Module

Deploys:
- Log Analytics Workspace
- Application Insights

## Outputs

After successful apply, Terraform outputs:

- `resource_group_name` - Resource group name
- `sql_server_fqdn` - SQL Server endpoint
- `api_url` - Backend API URL
- `frontend_url` - Frontend URL

## Configuration for GitHub Actions

To use Terraform in GitHub Actions:

1. Create a service principal:
   ```bash
   az ad sp create-for-rbac --name "sp-budgetbuddy-terraform" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. Add secrets to GitHub:
   - `AZURE_CREDENTIALS` - Full JSON output from above
   - `ARM_CLIENT_ID` - From JSON output
   - `ARM_CLIENT_SECRET` - From JSON output
   - `ARM_SUBSCRIPTION_ID` - Your subscription ID
   - `ARM_TENANT_ID` - Your tenant ID
   - `SQL_ADMIN_PASSWORD` - SQL Server password

3. Workflow automatically runs on infra changes

## Best Practices

- Use **modules** for reusability
- Separate **environments** (dev/prod)
- Use **remote state** for team collaboration
- Never commit **secrets** in code
- Use **Azure Key Vault** for sensitive values
- Tag all **resources** consistently
- Use **OIDC** authentication when possible

## Security

- SQL Server has firewall rules (configure appropriately)
- Use managed identities for app authentication
- Store secrets in Azure Key Vault
- Enable Azure Security Center recommendations

## Cost Optimization

Dev environment uses:
- Basic tier SQL Database
- Consumption-based Container Apps
- Shared Log Analytics workspace

For production, consider:
- Higher SQL tiers for performance
- Dedicated Container Apps plan
- Geo-redundancy options

## Cleanup

To destroy all resources:

```bash
cd infra/terraform/envs/dev
terraform destroy
```

**⚠️ Warning**: This will delete all resources!

## Troubleshooting

### State Lock Issues

If state is locked:
```bash
terraform force-unlock <lock-id>
```

### Provider Authentication

Ensure Azure CLI is authenticated:
```bash
az login
az account show
```

### Module Not Found

Ensure you've run `terraform init` after adding new modules.

## Additional Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Container Apps Docs](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure SQL Database Docs](https://docs.microsoft.com/en-us/azure/azure-sql/)
