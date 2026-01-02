# Troubleshooting Guide

Common issues and their solutions for BudgetBuddy.

## Table of Contents

- [Local Development Issues](#local-development-issues)
- [Build Issues](#build-issues)
- [Runtime Issues](#runtime-issues)
- [Database Issues](#database-issues)
- [Docker Issues](#docker-issues)
- [Azure Deployment Issues](#azure-deployment-issues)

## Local Development Issues

### Port Already in Use

**Problem:** Error: `port 5000 is already in use` or similar

**Solution:**
```bash
# Find process using the port (macOS/Linux)
lsof -i :5000

# Find process using the port (Windows)
netstat -ano | findstr :5000

# Kill the process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or use different ports in appsettings.json and .env
```

### Node Modules Issues

**Problem:** `Cannot find module` or dependency errors

**Solution:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### NuGet Package Restore Fails

**Problem:** Cannot restore NuGet packages

**Solution:**
```bash
cd backend/BudgetBuddy.Api

# Clear NuGet cache
dotnet nuget locals all --clear

# Restore packages
dotnet restore

# If still failing, check NuGet config
dotnet nuget list source
```

## Build Issues

### Backend Build Errors

#### Missing SDK

**Problem:** `The specified SDK 'Microsoft.NET.Sdk.Web' was not found`

**Solution:**
```bash
# Check .NET version
dotnet --version

# Install .NET 10 SDK
# Download from: https://dotnet.microsoft.com/download/dotnet/10.0
```

#### Assembly Not Found

**Problem:** `Could not load file or assembly...`

**Solution:**
```bash
cd backend/BudgetBuddy.Api

# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

### Frontend Build Errors

#### TypeScript Errors

**Problem:** Type errors during build

**Solution:**
```bash
cd frontend

# Check TypeScript version
npm list typescript

# Update TypeScript if needed
npm install --save-dev typescript@latest

# Fix import statements to use `type` imports where needed
# Example: import type { Budget } from './types';
```

#### Vite Build Fails

**Problem:** `[vite] error while building...`

**Solution:**
```bash
cd frontend

# Clear cache
rm -rf node_modules/.vite

# Rebuild
npm run build
```

## Runtime Issues

### Backend Returns 500 Errors

**Problem:** API returns Internal Server Error

**Diagnosis:**
```bash
# Check logs
cd backend/BudgetBuddy.Api
dotnet run

# Look for error messages in console
```

**Common Causes:**

1. **Database Connection**
   ```bash
   # Verify connection string in appsettings.json
   # Make sure SQL Server is running
   docker ps | grep sqlserver
   ```

2. **Missing Migration**
   ```bash
   # Apply migrations
   dotnet ef database update
   ```

3. **Null Reference**
   - Check that all required services are registered in Program.cs
   - Verify DTOs have required properties

### CORS Errors

**Problem:** `Access to fetch at 'http://localhost:5000' has been blocked by CORS policy`

**Solution:**
```csharp
// In Program.cs, ensure CORS is configured before routing
app.UseCors("AllowFrontend");
app.MapControllers();

// Verify frontend origin is in allowed origins
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:5173")  // Vite default port
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
```

### Frontend Can't Connect to API

**Problem:** Network errors or API not responding

**Checklist:**
1. ✅ Backend is running
2. ✅ Correct API URL in frontend/.env
3. ✅ CORS is configured
4. ✅ Firewall not blocking requests

**Test:**
```bash
# Test API directly
curl http://localhost:5000/api/budgets

# Check backend health
curl http://localhost:5000/health
```

## Database Issues

### Cannot Connect to SQL Server

**Problem:** `A connection was successfully established... but then an error occurred`

**Solution:**
```bash
# Check if SQL Server is running
docker ps | grep sqlserver

# Start SQL Server if not running
docker start sqlserver

# Or with Docker Compose
docker-compose up -d sqlserver

# Test connection
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong@Passw0rd" -C \
  -Q "SELECT @@VERSION"
```

### Migration Errors

**Problem:** `dotnet ef database update` fails

**Common Issues:**

1. **No migrations exist**
   ```bash
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

2. **Migration already applied**
   ```bash
   # List applied migrations
   dotnet ef migrations list
   
   # Remove last migration
   dotnet ef migrations remove
   ```

3. **Database in use**
   ```bash
   # Close all connections and try again
   # Or drop and recreate database
   dotnet ef database drop
   dotnet ef database update
   ```

### Seed Data Not Appearing

**Problem:** Database is empty after migration

**Solution:**
```bash
# Verify seed data is in DbContext.OnModelCreating
# Check that EnsureCreated or migrations were run

cd backend/BudgetBuddy.Api
dotnet ef database drop --force
dotnet ef database update
```

## Docker Issues

### Container Won't Start

**Problem:** `docker-compose up` fails

**Diagnosis:**
```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs backend
```

**Solutions:**

1. **Port conflicts**
   ```bash
   # Change ports in docker-compose.yml
   ports:
     - "5001:5000"  # Use 5001 instead
   ```

2. **Image build fails**
   ```bash
   # Rebuild images
   docker-compose build --no-cache
   docker-compose up
   ```

3. **Volume issues**
   ```bash
   # Remove volumes and restart
   docker-compose down -v
   docker-compose up
   ```

### SQL Server Container Fails

**Problem:** SQL Server container exits immediately

**Solution:**
```bash
# Check minimum requirements (4GB RAM for Docker Desktop)
# Ensure password meets complexity requirements

# Check logs
docker logs sqlserver

# Common issue: not enough memory
# Increase Docker Desktop memory to at least 4GB
```

### Build Context Too Large

**Problem:** `Sending build context to Docker daemon` takes forever

**Solution:**
```bash
# Add .dockerignore file
cat > backend/.dockerignore << EOF
bin/
obj/
node_modules/
.git/
.vs/
*.user
EOF

cat > frontend/.dockerignore << EOF
node_modules/
dist/
.git/
EOF
```

## Azure Deployment Issues

### Deployment Timeout

**Problem:** Azure deployment times out

**Solution:**
```bash
# Increase timeout in deployment script
# Use deployment slots for zero-downtime deployment

az webapp deployment slot create \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod \
  --slot staging

# Deploy to staging
az webapp deploy --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod \
  --slot staging \
  --src-path ./publish.zip

# Swap to production
az webapp deployment slot swap \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod \
  --slot staging
```

### App Service Won't Start

**Problem:** Azure App Service shows "Application Error"

**Diagnosis:**
```bash
# Stream logs
az webapp log tail \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# Download logs
az webapp log download \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod \
  --log-file logs.zip
```

**Common Causes:**

1. **Wrong runtime version**
   - Verify .NET 10 is selected
   - Check stack settings in Azure Portal

2. **Missing configuration**
   ```bash
   # Add connection string
   az webapp config connection-string set \
     --name app-budgetbuddy-backend-prod \
     --resource-group rg-budgetbuddy-prod \
     --connection-string-type SQLAzure \
     --settings DefaultConnection="<connection-string>"
   ```

3. **Startup command missing**
   ```bash
   # For .NET apps, usually not needed
   # But if required:
   az webapp config set \
     --name app-budgetbuddy-backend-prod \
     --resource-group rg-budgetbuddy-prod \
     --startup-file "dotnet BudgetBuddy.Api.dll"
   ```

### Database Firewall Issues

**Problem:** Backend can't connect to Azure SQL

**Solution:**
```bash
# Allow Azure services
az sql server firewall-rule create \
  --resource-group rg-budgetbuddy-prod \
  --server sql-budgetbuddy-prod \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Add your IP for testing
MY_IP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create \
  --resource-group rg-budgetbuddy-prod \
  --server sql-budgetbuddy-prod \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

### Terraform State Locked

**Problem:** `Error: Error acquiring the state lock`

**Solution:**
```bash
# List locks (if using Azure Storage backend)
az lock list \
  --resource-group tfstate-rg

# Force unlock (use with extreme caution)
terraform force-unlock <lock-id>

# If above doesn't work, manually delete lock in Azure Storage
az storage blob delete \
  --account-name <storage-account> \
  --container-name tfstate \
  --name budgetbuddy.tfstate.lock
```

## Performance Issues

### Slow API Responses

**Diagnosis:**
```bash
# Enable SQL logging to see queries
# In appsettings.Development.json:
{
  "Logging": {
    "LogLevel": {
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  }
}
```

**Common Causes:**

1. **N+1 Query Problem**
   ```csharp
   // BAD: Causes N+1 queries
   var budgets = await _context.Budgets.ToListAsync();
   foreach (var budget in budgets)
   {
       var transactions = await _context.Transactions
           .Where(t => t.BudgetId == budget.Id).ToListAsync();
   }
   
   // GOOD: Single query with Include
   var budgets = await _context.Budgets
       .Include(b => b.Transactions)
       .ToListAsync();
   ```

2. **Missing Index**
   ```csharp
   // Add index in DbContext
   modelBuilder.Entity<Transaction>()
       .HasIndex(t => t.BudgetId);
   ```

3. **Not using async/await**
   ```csharp
   // BAD: Blocks thread
   var budgets = _context.Budgets.ToList();
   
   // GOOD: Non-blocking
   var budgets = await _context.Budgets.ToListAsync();
   ```

### Large Bundle Size (Frontend)

**Problem:** Slow frontend load times

**Solution:**
```bash
# Analyze bundle
cd frontend
npm run build
npx vite-bundle-visualizer

# Common optimizations:
# 1. Use dynamic imports for routes
# 2. Remove unused dependencies
# 3. Enable compression in nginx
```

## Getting Help

If you can't resolve the issue:

1. Check [GitHub Issues](https://github.com/htekdev/budgeting-app/issues)
2. Search [GitHub Discussions](https://github.com/htekdev/budgeting-app/discussions)
3. Review [API Documentation](API.md)
4. Check [Deployment Guide](DEPLOYMENT.md)
5. Create a new issue with:
   - Detailed problem description
   - Steps to reproduce
   - Environment details
   - Error messages/logs
   - What you've tried

## Useful Commands

### Check Status
```bash
# Docker services
docker-compose ps

# .NET version
dotnet --version

# Node/NPM version
node --version
npm --version

# Azure CLI version
az --version

# Terraform version
terraform version
```

### Reset Everything
```bash
# Complete reset (nuclear option)
docker-compose down -v
rm -rf backend/BudgetBuddy.Api/bin backend/BudgetBuddy.Api/obj
rm -rf frontend/node_modules frontend/dist
cd backend/BudgetBuddy.Api && dotnet restore
cd ../../frontend && npm install
docker-compose up -d
```

### View Logs
```bash
# Backend
cd backend/BudgetBuddy.Api && dotnet run

# Docker Compose
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Azure
az webapp log tail --name <app-name> --resource-group <rg-name>
```

---

**Remember:** When in doubt, check the logs first! Most issues have clear error messages if you know where to look.
