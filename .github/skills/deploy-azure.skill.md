# Deploy to Azure Skill

Step-by-step guide to deploy BudgetBuddy to Azure.

## Prerequisites
- Azure subscription
- Azure CLI installed
- Terraform installed
- GitHub repository access
- Docker installed (for container deployments)

## Option 1: Deploy Using Terraform

### 1. Setup Azure CLI
```bash
az login
az account set --subscription <subscription-id>
```

### 2. Create Terraform Backend Storage
```bash
az group create --name tfstate-rg --location eastus
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)"
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT_NAME
```

### 3. Configure Terraform Variables
Create `infrastructure/terraform/terraform.tfvars`:
```hcl
environment        = "prod"
location           = "eastus"
sql_admin_password = "YourSecurePassword123!"
```

### 4. Deploy Infrastructure
```bash
cd infrastructure/terraform
terraform init \
  -backend-config="resource_group_name=tfstate-rg" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=budgetbuddy.tfstate"

terraform plan
terraform apply
```

### 5. Deploy Applications

#### Backend
```bash
cd backend/BudgetBuddy.Api
dotnet publish -c Release -o ./publish
cd publish
zip -r ../app.zip .
az webapp deployment source config-zip \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-backend-prod \
  --src ../app.zip
```

#### Frontend
```bash
cd frontend
npm run build
cd dist
zip -r ../app.zip .
az webapp deployment source config-zip \
  --resource-group rg-budgetbuddy-prod \
  --name app-budgetbuddy-frontend-prod \
  --src ../app.zip
```

## Option 2: Deploy Using GitHub Actions

### 1. Setup Azure Credentials
Create a service principal:
```bash
az ad sp create-for-rbac \
  --name "budgetbuddy-deploy" \
  --role contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

### 2. Add GitHub Secrets
Add these secrets to your GitHub repository:
- `AZURE_CREDENTIALS`: Output from service principal creation
- `AZURE_SUBSCRIPTION_ID`: Your subscription ID
- `SQL_ADMIN_PASSWORD`: SQL Server admin password

### 3. Create Deployment Workflow
See `.github/workflows/deploy.yml` for automated deployment.

## Option 3: Deploy Using Azure Container Apps

### 1. Build and Push Docker Images
```bash
# Backend
docker build -t budgetbuddy-backend:latest ./backend
docker tag budgetbuddy-backend:latest <registry>.azurecr.io/budgetbuddy-backend:latest
docker push <registry>.azurecr.io/budgetbuddy-backend:latest

# Frontend
docker build -t budgetbuddy-frontend:latest ./frontend
docker tag budgetbuddy-frontend:latest <registry>.azurecr.io/budgetbuddy-frontend:latest
docker push <registry>.azurecr.io/budgetbuddy-frontend:latest
```

### 2. Create Container Apps
```bash
az containerapp create \
  --name budgetbuddy-backend \
  --resource-group rg-budgetbuddy-prod \
  --image <registry>.azurecr.io/budgetbuddy-backend:latest \
  --environment myenvironment \
  --target-port 5000
```

## Post-Deployment

### 1. Run Database Migrations
```bash
# Connect to Azure SQL
dotnet ef database update --connection "<azure-connection-string>"
```

### 2. Verify Deployment
- Check backend health: `https://<backend-url>/health`
- Check Swagger UI: `https://<backend-url>/swagger`
- Test frontend: `https://<frontend-url>`

### 3. Configure Custom Domain (Optional)
```bash
az webapp config hostname add \
  --webapp-name app-budgetbuddy-frontend-prod \
  --resource-group rg-budgetbuddy-prod \
  --hostname www.yourbudgetbuddy.com
```

### 4. Enable SSL
```bash
az webapp config ssl bind \
  --name app-budgetbuddy-frontend-prod \
  --resource-group rg-budgetbuddy-prod \
  --certificate-thumbprint <thumbprint> \
  --ssl-type SNI
```

## Monitoring

### Enable Application Insights
The Terraform configuration automatically creates Application Insights. View metrics at:
- Azure Portal > Application Insights > budgetbuddy-appinsights

### Check Logs
```bash
az webapp log tail \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod
```

## Troubleshooting

### Database Connection Issues
- Verify firewall rules allow Azure services
- Check connection string in app settings
- Ensure managed identity has database access

### App Won't Start
- Check application logs
- Verify environment variables
- Check App Service plan SKU supports the app
- Verify Docker container is healthy

### Frontend Can't Connect to Backend
- Update VITE_API_URL environment variable
- Check CORS configuration
- Verify backend is running and healthy
