# Deployment Guide

This guide covers deploying BudgetBuddy to various environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Azure Deployment](#azure-deployment)
- [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) v2.50+
- [Terraform](https://www.terraform.io/downloads.html) v1.6+
- [.NET SDK](https://dotnet.microsoft.com/download) v10.0+
- [Node.js](https://nodejs.org/) v20+
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (for local dev)
- [Git](https://git-scm.com/)

### Azure Requirements

- Active Azure subscription
- Sufficient permissions to create resources
- Azure subscription ID
- Resource group location preference

## Local Development

### Quick Start with Docker Compose

```bash
# Clone the repository
git clone https://github.com/htekdev/budgeting-app.git
cd budgeting-app

# Start all services
docker-compose up -d

# Check services are running
docker-compose ps

# Access the application
# Frontend: http://localhost:3000
# Backend: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

### Manual Local Setup

#### 1. Database Setup

```bash
# Start SQL Server
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

#### 2. Backend Setup

```bash
cd backend/BudgetBuddy.Api

# Restore dependencies
dotnet restore

# Apply migrations
dotnet ef database update

# Run the API
dotnet run

# API will be available at http://localhost:5000
```

#### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Frontend will be available at http://localhost:5173
```

## Azure Deployment

### Option 1: Terraform (Recommended)

#### Step 1: Setup Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription <subscription-id>

# Create resource group for Terraform state
az group create --name tfstate-rg --location eastus

# Create storage account for Terraform state
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)"
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT_NAME
```

#### Step 2: Configure Terraform

Create `infrastructure/terraform/terraform.tfvars`:

```hcl
environment        = "prod"
location           = "eastus"
sql_admin_password = "YourSecurePassword123!"
```

**⚠️ IMPORTANT: Never commit this file! It's in .gitignore**

#### Step 3: Deploy Infrastructure

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init \
  -backend-config="resource_group_name=tfstate-rg" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=budgetbuddy.tfstate"

# Review planned changes
terraform plan

# Apply changes
terraform apply

# Save outputs
terraform output > outputs.txt
```

#### Step 4: Deploy Applications

**Backend:**
```bash
cd backend/BudgetBuddy.Api

# Publish the application
dotnet publish -c Release -o ./publish

# Create deployment package
cd publish
zip -r ../deploy.zip .

# Get app name from Terraform outputs
BACKEND_APP_NAME=$(cd ../../infrastructure/terraform && terraform output -raw backend_app_name)

# Deploy
az webapp deployment source config-zip \
  --resource-group rg-budgetbuddy-prod \
  --name $BACKEND_APP_NAME \
  --src ../deploy.zip
```

**Frontend:**
```bash
cd frontend

# Build the application
npm run build

# Create deployment package
cd dist
zip -r ../deploy.zip .

# Get app name from Terraform outputs
FRONTEND_APP_NAME=$(cd ../infrastructure/terraform && terraform output -raw frontend_app_name)

# Deploy
az webapp deployment source config-zip \
  --resource-group rg-budgetbuddy-prod \
  --name $FRONTEND_APP_NAME \
  --src ../deploy.zip
```

**Run Migrations:**
```bash
cd backend/BudgetBuddy.Api

# Get connection string from Azure
CONNECTION_STRING=$(az sql db show-connection-string \
  --name sqldb-budgetbuddy-prod \
  --server sql-budgetbuddy-prod \
  --client ado.net \
  --output tsv)

# Run migrations
dotnet ef database update --connection "$CONNECTION_STRING"
```

### Option 2: Azure Portal (Manual)

1. **Create Resources:**
   - App Service Plan (Linux, B1 SKU)
   - Two Web Apps (backend and frontend)
   - SQL Server and Database
   - Application Insights

2. **Configure Backend Web App:**
   - Runtime: .NET 10
   - Add connection string in Configuration
   - Enable managed identity
   - Configure health check path: `/health`

3. **Configure Frontend Web App:**
   - Runtime: Node.js 20
   - Add API URL in app settings
   - Configure deployment source

4. **Deploy Applications:**
   - Use VS Code Azure extension
   - Or use Azure CLI as shown above

## CI/CD with GitHub Actions

### Setup

#### 1. Create Azure Service Principal

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "budgetbuddy-deploy" \
  --role contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth > azure-credentials.json
```

#### 2. Configure GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `AZURE_CLIENT_ID` | Service principal client ID | From azure-credentials.json |
| `AZURE_TENANT_ID` | Azure tenant ID | From azure-credentials.json |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `az account show --query id` |
| `SQL_ADMIN_PASSWORD` | SQL Server admin password | Create secure password |
| `TF_STATE_RG` | Terraform state resource group | `tfstate-rg` |
| `TF_STATE_STORAGE` | Terraform state storage account | From setup |
| `DATABASE_CONNECTION_STRING` | Database connection for migrations | From Azure Portal |

#### 3. Enable OIDC (Recommended)

For better security, use OIDC instead of credentials:

```bash
# Configure federated credentials
az ad app federated-credential create \
  --id <app-id> \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:htekdev/budgeting-app:environment:prod",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Automated Deployment

#### Trigger Deployment

```bash
# Go to Actions tab in GitHub
# Select "Deploy to Azure" workflow
# Click "Run workflow"
# Choose environment (dev/staging/prod)
```

Or trigger via API:
```bash
gh workflow run deploy.yml \
  --ref main \
  --field environment=prod
```

## Post-Deployment

### 1. Verify Deployment

```bash
# Check backend health
curl https://app-budgetbuddy-backend-prod.azurewebsites.net/health

# Check frontend
curl https://app-budgetbuddy-frontend-prod.azurewebsites.net

# Check Swagger
open https://app-budgetbuddy-backend-prod.azurewebsites.net/swagger
```

### 2. Configure Custom Domain (Optional)

```bash
# Add custom domain
az webapp config hostname add \
  --webapp-name app-budgetbuddy-frontend-prod \
  --resource-group rg-budgetbuddy-prod \
  --hostname www.yourbudgetbuddy.com

# Create SSL certificate
az webapp config ssl create \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-frontend-prod \
  --hostname www.yourbudgetbuddy.com

# Bind SSL
az webapp config ssl bind \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-frontend-prod \
  --certificate-thumbprint <thumbprint> \
  --ssl-type SNI
```

### 3. Setup Monitoring

```bash
# Enable Application Insights alerts
az monitor metrics alert create \
  --name high-error-rate \
  --resource-group rg-budgetbuddy-prod \
  --scopes /subscriptions/<sub-id>/resourceGroups/rg-budgetbuddy-prod/providers/Microsoft.Web/sites/app-budgetbuddy-backend-prod \
  --condition "avg requests/failed > 10" \
  --window-size 5m \
  --evaluation-frequency 1m
```

### 4. Configure Backup (Production)

```bash
# Create storage account for backups
az storage account create \
  --name budgetbuddybackups \
  --resource-group rg-budgetbuddy-prod \
  --location eastus \
  --sku Standard_GRS

# Configure web app backup
az webapp config backup create \
  --resource-group rg-budgetbuddy-prod \
  --webapp-name app-budgetbuddy-backend-prod \
  --container-url <storage-container-url> \
  --backup-name daily-backup \
  --frequency 1d \
  --retain-one true \
  --retention-period-in-days 30
```

## Troubleshooting

### Backend Issues

#### Application Won't Start
```bash
# Check logs
az webapp log tail \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# Check application settings
az webapp config appsettings list \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod
```

#### Database Connection Errors
```bash
# Verify connection string
az webapp config connection-string list \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# Check firewall rules
az sql server firewall-rule list \
  --resource-group rg-budgetbuddy-prod \
  --server sql-budgetbuddy-prod
```

### Frontend Issues

#### Build Failures
```bash
# Check build logs in Azure Portal
# Or redeploy with verbose logging
az webapp deploy \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-frontend-prod \
  --src-path ./dist \
  --type zip \
  --async true
```

#### API Connection Issues
```bash
# Verify API URL environment variable
az webapp config appsettings show \
  --name app-budgetbuddy-frontend-prod \
  --resource-group rg-budgetbuddy-prod \
  --query "[?name=='VITE_API_URL']"
```

### Terraform Issues

#### State Lock
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

#### Drift Detection
```bash
# Check for configuration drift
terraform plan -detailed-exitcode

# Exit code 0 = no changes
# Exit code 1 = error
# Exit code 2 = changes needed
```

## Rollback Procedures

### Application Rollback

```bash
# List deployment slots
az webapp deployment list-publishing-profiles \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# Swap slots to rollback
az webapp deployment slot swap \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-backend-prod \
  --slot staging \
  --target-slot production
```

### Database Rollback

```bash
# Revert to previous migration
cd backend/BudgetBuddy.Api
dotnet ef database update <PreviousMigrationName>
```

### Infrastructure Rollback

```bash
# Revert to previous Terraform state
cd infrastructure/terraform
terraform state pull > current-state.json
terraform state push previous-state.json
terraform apply
```

## Best Practices

1. **Always test in dev/staging first**
2. **Use deployment slots for zero-downtime deployments**
3. **Backup database before migrations**
4. **Monitor deployments for 30 minutes post-deployment**
5. **Keep deployment documentation updated**
6. **Use infrastructure as code (Terraform)**
7. **Implement proper secret management**
8. **Enable monitoring and alerting**

## Support

For deployment issues:
- Check [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
- Review [GitHub Issues](https://github.com/htekdev/budgeting-app/issues)
- Contact DevOps team

---

**Last Updated:** 2026-01-02
**Version:** 1.0.0
