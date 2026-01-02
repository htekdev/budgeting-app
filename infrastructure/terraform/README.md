# Terraform Infrastructure for BudgetBuddy

This directory contains Terraform configurations for deploying BudgetBuddy to Azure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription

## Resources Created

- Resource Group
- App Service Plan (Linux, B1 SKU)
- App Service for Backend (ASP.NET Core 10)
- App Service for Frontend (Node.js 20)
- SQL Server
- SQL Database
- Application Insights

## Setup

1. **Login to Azure:**
   ```bash
   az login
   ```

2. **Create a backend storage account for Terraform state (optional but recommended):**
   ```bash
   az group create --name tfstate-rg --location eastus
   az storage account create --name tfstate<uniqueid> --resource-group tfstate-rg --location eastus --sku Standard_LRS
   az storage container create --name tfstate --account-name tfstate<uniqueid>
   ```

3. **Initialize Terraform:**
   ```bash
   cd infrastructure/terraform
   terraform init
   ```

4. **Create a `terraform.tfvars` file:**
   ```hcl
   environment         = "dev"
   location            = "eastus"
   sql_admin_password  = "YourSecurePassword123!"
   ```

5. **Plan the deployment:**
   ```bash
   terraform plan
   ```

6. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name | `dev` |
| `location` | Azure region | `eastus` |
| `app_name` | Application name | `budgetbuddy` |
| `sql_admin_username` | SQL admin username | `sqladmin` |
| `sql_admin_password` | SQL admin password | (required) |

## Outputs

After successful deployment, Terraform will output:
- Backend URL
- Frontend URL
- SQL Server FQDN
- Database name
- Application Insights connection string

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Security Notes

- Never commit `terraform.tfvars` or any files containing secrets
- Use Azure Key Vault for production secrets
- Enable Azure AD authentication for SQL Server
- Configure network security groups as needed
- Review and adjust firewall rules for production
