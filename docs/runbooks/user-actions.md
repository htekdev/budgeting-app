# User Actions Required

This document lists all manual actions that must be performed by users to fully set up and deploy the BudgetBuddy application. These actions are outside the scope of automated agent tasks.

## 🚨 Required Before First Use

### 1. Azure Subscription Setup (For Cloud Deployment)

**Action**: Create or use existing Azure subscription

**Steps**:
1. Go to [Azure Portal](https://portal.azure.com)
2. Sign in or create an account
3. Create a subscription if you don't have one
4. Note your Subscription ID

**Why Manual**: Requires credit card and account verification

---

### 2. GitHub Repository Secrets

**Action**: Add secrets to GitHub repository

**Required Secrets**:
```
AZURE_CREDENTIALS       - Service principal JSON for Azure authentication
ARM_CLIENT_ID          - Azure service principal client ID
ARM_CLIENT_SECRET      - Azure service principal secret
ARM_SUBSCRIPTION_ID    - Azure subscription ID
ARM_TENANT_ID          - Azure tenant ID
SQL_ADMIN_PASSWORD     - SQL Server administrator password
```

**Steps**:
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret above

**Why Manual**: Secrets cannot be created via API without existing authentication

---

### 3. Azure Service Principal Creation

**Action**: Create service principal for GitHub Actions

**Commands**:
```bash
# Login to Azure CLI
az login

# Create service principal
az ad sp create-for-rbac \
  --name "sp-budgetbuddy-github" \
  --role contributor \
  --scopes /subscriptions/{your-subscription-id} \
  --sdk-auth

# Copy the JSON output and save as AZURE_CREDENTIALS secret
```

**Why Manual**: Requires Azure CLI authentication and permissions

---

### 4. Terraform Remote State Setup (Optional but Recommended)

**Action**: Create Azure Storage for Terraform state

**Commands**:
```bash
# Create resource group for Terraform state
az group create \
  --name rg-budgetbuddy-tfstate \
  --location eastus

# Create storage account
az storage account create \
  --name stbudgetbuddytfstate \
  --resource-group rg-budgetbuddy-tfstate \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name stbudgetbuddytfstate

# Update infra/terraform/envs/dev/providers.tf with backend config
```

**Why Manual**: One-time infrastructure setup

---

### 5. Local Development Environment

**Action**: Install required software

**Required Software**:
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Node.js 20+](https://nodejs.org/)
- (Optional) [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- (Optional) [Terraform](https://www.terraform.io/downloads)

**Why Manual**: Requires system administrator privileges

---

### 6. Database Password Configuration

**Action**: Set SQL Server password for local development

**Options**:

**Option A - Environment Variable**:
```bash
# Linux/Mac
export SQL_PASSWORD='YourStrong!Passw0rd'

# Windows PowerShell
$env:SQL_PASSWORD='YourStrong!Passw0rd'
```

**Option B - Docker Compose Override**:
Create `docker-compose.override.yml`:
```yaml
version: '3.8'
services:
  sqlserver:
    environment:
      - MSSQL_SA_PASSWORD=YourCustomPassword123!
```

**Why Manual**: Security best practice - passwords shouldn't be in source control

---

## 🔧 Optional Configuration

### 7. GitHub Codespaces Secrets

**Action**: Add secrets for Codespaces (if using)

**Steps**:
1. Go to GitHub Settings → Codespaces
2. Add codespace secrets if needed
3. These are separate from repository secrets

**Why Manual**: Codespaces configuration is per-user

---

### 8. Azure Container Registry

**Action**: Create Azure Container Registry (if not using Docker Hub)

**Commands**:
```bash
az acr create \
  --resource-group rg-budgetbuddy-dev \
  --name acrbudgetbuddydev \
  --sku Basic

# Enable admin user
az acr update \
  --name acrbudgetbuddydev \
  --admin-enabled true

# Get credentials
az acr credential show --name acrbudgetbuddydev
```

**Why Manual**: Requires Azure resources and authentication

---

### 9. GitHub Actions Environment Setup

**Action**: Create deployment environments with protection rules

**Steps**:
1. Go to repository Settings → Environments
2. Create "dev" and "prod" environments
3. Add protection rules (required reviewers, wait timer)
4. Add environment-specific secrets

**Why Manual**: Protection rules are security policy decisions

---

### 10. Domain Name and SSL (Production)

**Action**: Configure custom domain and SSL certificate

**Steps**:
1. Purchase or use existing domain
2. Configure DNS records to point to Azure resources
3. Add custom domain in Azure Container Apps
4. Configure SSL certificate (Azure provides free SSL)

**Why Manual**: Domain ownership verification required

---

## ✅ Verification Steps

After completing required actions, verify:

1. **GitHub Secrets**:
   - All required secrets are added
   - Secret values are correct (test with a workflow run)

2. **Azure Access**:
   ```bash
   az login
   az account show
   ```

3. **Local Docker**:
   ```bash
   docker --version
   docker compose version
   docker ps
   ```

4. **Local .NET**:
   ```bash
   dotnet --version
   # Should show 8.x.x
   ```

5. **Local Node**:
   ```bash
   node --version
   npm --version
   # Node should be 20+
   ```

6. **Terraform** (if using):
   ```bash
   terraform --version
   # Should show 1.6+
   ```

---

## 🆘 Troubleshooting

### Issue: GitHub Actions fail with authentication error

**Solution**: Verify Azure credentials in GitHub Secrets are correct

### Issue: Docker Compose fails to start SQL Server

**Solution**: 
- Ensure Docker Desktop is running
- Check available memory (SQL Server needs ~2GB)
- Verify password meets complexity requirements

### Issue: Terraform plan fails

**Solution**:
- Run `az login` to authenticate
- Verify subscription ID is correct
- Check service principal permissions

### Issue: Can't connect to database locally

**Solution**:
- Verify SQL Server container is running: `docker ps`
- Check connection string
- Ensure password is correct
- Try: `sqlcmd -S localhost -U sa -P 'YourPassword' -C`

---

## 📞 Support

For issues with:
- **Azure**: [Azure Support](https://azure.microsoft.com/support/)
- **GitHub**: [GitHub Support](https://support.github.com/)
- **Docker**: [Docker Documentation](https://docs.docker.com/)
- **Application Issues**: Create an issue in this repository

---

## 📋 Checklist

Use this checklist to track completion:

- [ ] Azure subscription active
- [ ] GitHub secrets configured
- [ ] Service principal created
- [ ] Terraform state storage created (optional)
- [ ] Local development software installed
- [ ] Database password configured
- [ ] Verified all tools work locally
- [ ] (Optional) Container registry created
- [ ] (Optional) GitHub environments configured
- [ ] (Optional) Custom domain configured
