# BudgetBuddy Local Setup Guide

This guide will help you set up the BudgetBuddy application on your local machine for development.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Git** (2.40+)
   ```bash
   git --version
   ```
   Download: https://git-scm.com/

2. **.NET SDK 10** (10.0.100+)
   ```bash
   dotnet --version
   ```
   Download: https://dotnet.microsoft.com/download/dotnet/10.0

3. **Node.js** (20.x LTS)
   ```bash
   node --version
   npm --version
   ```
   Download: https://nodejs.org/

4. **Docker Desktop** (24.0+)
   ```bash
   docker --version
   docker-compose --version
   ```
   Download: https://www.docker.com/products/docker-desktop

### Optional but Recommended

5. **Visual Studio Code**
   - Download: https://code.visualstudio.com/
   - Extensions:
     - C# Dev Kit
     - ESLint
     - Prettier
     - Docker
     - GitHub Copilot (if available)

6. **SQL Server Management Studio** (SSMS) or **Azure Data Studio**
   - For database management and querying
   - Download: https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms

## Setup Methods

Choose one of three setup methods based on your preference:

- **Method 1**: GitHub Codespaces (Easiest, cloud-based)
- **Method 2**: Docker Compose (Recommended for local dev)
- **Method 3**: Manual Setup (Full control)

---

## Method 1: GitHub Codespaces (Easiest)

GitHub Codespaces provides a fully configured development environment in the cloud.

### Steps

1. **Open Repository in Codespace**
   - Navigate to https://github.com/htekdev/budgeting-app
   - Click the green **"Code"** button
   - Select **"Codespaces"** tab
   - Click **"Create codespace on main"**

2. **Wait for Environment Setup**
   - The devcontainer will automatically:
     - Install .NET 10 SDK
     - Install Node.js 20
     - Start SQL Server
     - Restore backend dependencies
     - Build backend
     - Install frontend dependencies
   - Setup takes about 3-5 minutes

3. **Verify Installation**
   ```bash
   # Backend
   cd src/backend/BudgetBuddy.API
   dotnet run
   
   # In a new terminal - Frontend
   cd src/frontend
   npm run dev
   ```

4. **Access Application**
   - Backend API: http://localhost:5000
   - Frontend: http://localhost:3000
   - Swagger UI: http://localhost:5000/swagger

5. **Stop Services**
   - Press `Ctrl+C` in each terminal

### Troubleshooting Codespaces

If setup fails:
```bash
# Restart postCreateCommand manually
bash .devcontainer/post-create.sh

# Check SQL Server status
docker ps | grep sqlserver

# Check logs
docker-compose logs
```

---

## Method 2: Docker Compose (Recommended)

Use Docker Compose to run all services in containers.

### Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/htekdev/budgeting-app.git
   cd budgeting-app
   ```

2. **Start All Services**
   ```bash
   docker-compose up -d
   ```
   
   This starts:
   - SQL Server (port 1433)
   - Backend API (port 5000)
   - Frontend (port 3000)

3. **Wait for Services**
   ```bash
   # Wait about 60 seconds for SQL Server to initialize
   # Check service status
   docker-compose ps
   
   # View logs
   docker-compose logs -f
   ```

4. **Verify Services**
   - Backend API: http://localhost:5000/health (should return "Healthy")
   - Frontend: http://localhost:3000
   - Swagger UI: http://localhost:5000/swagger

5. **Stop Services**
   ```bash
   docker-compose down
   ```

6. **Clean Up (if needed)**
   ```bash
   # Remove volumes (deletes database data)
   docker-compose down -v
   
   # Remove images
   docker-compose down --rmi all
   ```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose stop

# Restart a specific service
docker-compose restart backend

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Access SQL Server
docker exec -it budgetbuddy-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C
```

### Troubleshooting Docker Compose

**SQL Server not starting**:
```bash
# Check logs
docker-compose logs sqlserver

# Common issue: Not enough memory
# Solution: Increase Docker memory to at least 4GB in Docker Desktop settings
```

**Backend not connecting to database**:
```bash
# Verify SQL Server is running
docker ps | grep sqlserver

# Check connection string in docker-compose.yml
# Ensure: Server=sqlserver (not localhost)
```

**Frontend can't reach backend**:
```bash
# Check backend is running
curl http://localhost:5000/health

# Verify CORS settings in backend Program.cs
```

---

## Method 3: Manual Setup

Run each component separately for full control.

### Step 1: Clone Repository

```bash
git clone https://github.com/htekdev/budgeting-app.git
cd budgeting-app
```

### Step 2: Setup SQL Server

**Option A: Docker Container**
```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
   -p 1433:1433 --name budgetbuddy-sql \
   -d mcr.microsoft.com/mssql/server:2022-latest
```

**Option B: Local SQL Server Installation**
- Install SQL Server 2019/2022
- Create database: `BudgetBuddyDB`
- Note connection details for next step

### Step 3: Configure Backend

1. **Navigate to backend**
   ```bash
   cd src/backend
   ```

2. **Update connection string**
   
   Edit `BudgetBuddy.API/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost;Database=BudgetBuddyDB;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True"
     }
   }
   ```

3. **Restore dependencies**
   ```bash
   dotnet restore
   ```

4. **Build solution**
   ```bash
   dotnet build
   ```

5. **Run migrations**
   ```bash
   cd BudgetBuddy.API
   dotnet ef database update
   ```
   
   If `dotnet ef` is not installed:
   ```bash
   dotnet tool install --global dotnet-ef
   ```

6. **Run backend**
   ```bash
   dotnet run
   ```
   
   Backend will start on:
   - HTTPS: https://localhost:5001
   - HTTP: http://localhost:5000

7. **Verify backend**
   - Open: http://localhost:5000/health
   - Should see: `{"status":"Healthy"}`
   - Swagger: http://localhost:5000/swagger

### Step 4: Setup Frontend

1. **Open new terminal, navigate to frontend**
   ```bash
   cd src/frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure API URL (optional)**
   
   Create `.env.local`:
   ```
   VITE_API_URL=http://localhost:5000
   ```

4. **Run frontend**
   ```bash
   npm run dev
   ```
   
   Frontend will start on: http://localhost:3000

5. **Open in browser**
   - Navigate to http://localhost:3000
   - You should see the BudgetBuddy homepage

### Step 5: Run Tests

**Backend tests**:
```bash
cd src/backend
dotnet test
```

**Frontend tests**:
```bash
cd src/frontend
npm test
```

### Manual Setup Troubleshooting

**Migration fails**:
```bash
# Check SQL Server is running
# Try creating database manually
sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "CREATE DATABASE BudgetBuddyDB"

# Then run migrations again
dotnet ef database update
```

**Port already in use**:
```bash
# Backend
# Edit src/backend/BudgetBuddy.API/Properties/launchSettings.json
# Change "applicationUrl" ports

# Frontend
# Run on different port
npm run dev -- --port 3001
```

**EF Core tools not found**:
```bash
# Install globally
dotnet tool install --global dotnet-ef

# Or install locally in project
dotnet tool install dotnet-ef
```

---

## Verify Installation

After completing any method, verify everything works:

### 1. Check Services
```bash
# Backend health check
curl http://localhost:5000/health
# Expected: {"status":"Healthy"}

# List budgets (with seed data)
curl http://localhost:5000/api/budgets
# Expected: JSON array of budgets

# Frontend
# Open: http://localhost:3000
# Should see application UI
```

### 2. Run Self-Audit
```bash
# In repository root
npm install
npm run self:audit
```

This runs comprehensive checks on:
- Backend build and tests
- Frontend linting and type checking
- Project structure
- Copilot customization files
- Infrastructure files

### 3. Test API Endpoints

Use Swagger UI or curl:

```bash
# Get all budgets
curl http://localhost:5000/api/budgets

# Get specific budget
curl http://localhost:5000/api/budgets/{id}

# Create budget (POST)
curl -X POST http://localhost:5000/api/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Budget",
    "description": "Testing",
    "totalAmount": 1000,
    "startDate": "2026-01-01",
    "endDate": "2026-01-31",
    "userId": "00000000-0000-0000-0000-000000000000"
  }'
```

---

## Development Workflow

### Daily Development

1. **Start services**
   ```bash
   # Docker Compose
   docker-compose up -d
   
   # OR Manual
   # Terminal 1: Backend
   cd src/backend/BudgetBuddy.API && dotnet run
   
   # Terminal 2: Frontend
   cd src/frontend && npm run dev
   ```

2. **Make changes**
   - Edit code in your favorite editor
   - Changes auto-reload (hot reload)

3. **Test changes**
   ```bash
   # Backend
   dotnet test
   
   # Frontend
   npm test
   ```

4. **Commit and push**
   ```bash
   git add .
   git commit -m "Your message"
   git push
   ```

### Adding Database Changes

1. **Modify entity in `src/backend/BudgetBuddy.Domain/Entities/`**

2. **Update DbContext configuration if needed**
   - Edit `src/backend/BudgetBuddy.Infrastructure/Data/BudgetBuddyDbContext.cs`

3. **Create migration**
   ```bash
   cd src/backend/BudgetBuddy.API
   dotnet ef migrations add YourMigrationName
   ```

4. **Review migration**
   - Check `src/backend/BudgetBuddy.Infrastructure/Migrations/`

5. **Apply migration**
   ```bash
   dotnet ef database update
   ```

### Adding API Endpoint

1. **Add endpoint in `src/backend/BudgetBuddy.API/Program.cs`**

2. **Build and test**
   ```bash
   dotnet build
   dotnet run
   ```

3. **Test with Swagger** at http://localhost:5000/swagger

4. **Update frontend API client**
   ```bash
   cd src/frontend
   # Generate client from OpenAPI spec
   npx swagger-typescript-api -p http://localhost:5000/openapi/v1.json -o ./src/api -n client.ts
   ```

---

## Common Issues

### Issue: Port Already in Use

**Solution**:
```bash
# Find process using port (Linux/Mac)
lsof -i :5000
kill -9 <PID>

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Issue: Database Connection Failed

**Solutions**:
1. Verify SQL Server is running
2. Check connection string
3. Verify SQL Server accepts TCP connections
4. Check firewall settings

### Issue: npm install fails

**Solution**:
```bash
# Clear cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: dotnet restore fails

**Solution**:
```bash
# Clear NuGet cache
dotnet nuget locals all --clear

# Restore with verbose output
dotnet restore --verbosity detailed
```

---

## Next Steps

After successful setup:

1. **Explore the code**
   - Review domain models in `src/backend/BudgetBuddy.Domain/`
   - Check API endpoints in `src/backend/BudgetBuddy.API/Program.cs`
   - Examine React components in `src/frontend/src/`

2. **Review documentation**
   - [System Design](../architecture/system-design.md)
   - [Database Schema](../architecture/database-schema.md)
   - [AGENTS.md](../../AGENTS.md) - Custom Copilot agents

3. **Start developing**
   - Use GitHub Copilot agents for assistance
   - Follow code patterns in `.github/copilot-instructions.md`
   - Run `npm run self:audit` before committing

4. **Contribute**
   - See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines
   - Create feature branches
   - Submit pull requests

---

## Getting Help

- 📖 [Full Documentation](../../docs/)
- 🐛 [Report Issues](https://github.com/htekdev/budgeting-app/issues)
- 💬 [Discussions](https://github.com/htekdev/budgeting-app/discussions)
- 🤖 Use GitHub Copilot agents: `@backend_expert`, `@frontend_expert`, `@devops_expert`
