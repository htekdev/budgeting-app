# BudgetBuddy - Repository Custom Instructions

## Project Overview

BudgetBuddy is a full-stack budgeting application built to showcase GitHub Copilot capabilities across the entire Software Development Lifecycle (SDLC). This repository demonstrates:

- **Frontend**: React + TypeScript with Vite, React Query, React Router
- **Backend**: ASP.NET Core 8 Web API with layered architecture (Domain, Application, Infrastructure)
- **Database**: SQL Server with Entity Framework Core migrations
- **Infrastructure**: Terraform modules for Azure deployment
- **DevOps**: GitHub Actions CI/CD, Docker Compose for local dev, Codespaces support

## Repository Structure

```
/
├── src/
│   ├── frontend/          # React + TypeScript frontend
│   └── backend/           # ASP.NET Core backend
│       ├── BudgetBuddy.Api/
│       ├── BudgetBuddy.Domain/
│       ├── BudgetBuddy.Application/
│       ├── BudgetBuddy.Infrastructure/
│       └── BudgetBuddy.Tests/
├── db/
│   ├── schema/            # SQL schema scripts
│   └── migrations/        # EF Core migrations
├── infra/terraform/       # Infrastructure as Code
├── .devcontainer/         # Codespaces configuration
├── .github/
│   ├── workflows/         # CI/CD workflows
│   ├── instructions/      # Path-scoped Copilot instructions
│   ├── agents/            # Custom agent definitions
│   └── skills/            # Agent skills
└── docs/                  # Documentation
```

## Build, Test, and Lint Commands

### Backend (.NET 8)

```bash
cd src/backend

# Restore dependencies
dotnet restore

# Build
dotnet build BudgetBuddy.sln

# Run tests
dotnet test

# Run API locally
dotnet run --project BudgetBuddy.Api

# Apply EF migrations
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

### Frontend (React + TypeScript)

```bash
cd src/frontend

# Install dependencies
npm install

# Lint
npm run lint

# Type check
npm run type-check  # if configured

# Build
npm run build

# Run dev server
npm run dev

# Format code
npm run format  # if configured
```

### Database

```bash
# Connect to SQL Server
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C

# Run schema scripts manually (if not using EF migrations)
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -d BudgetBuddy -i db/schema/001_create_tables.sql
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]
```

### Terraform

```bash
cd infra/terraform/envs/dev

# Initialize
terraform init

# Format
terraform fmt -recursive

# Validate
terraform validate

# Plan
terraform plan

# Apply
terraform apply
```

## Coding Conventions

### C# / .NET

- Use **C# 12** features
- Follow **Clean Architecture** principles (Domain, Application, Infrastructure, API)
- Use **async/await** for all I/O operations
- Implement **repository pattern** in Infrastructure layer
- Use **DTOs** for API requests/responses (not domain entities directly)
- Use **ProblemDetails** for error responses
- Add **XML comments** for public APIs
- Use **dependency injection** via `Program.cs`
- Naming: `PascalCase` for classes/methods, `camelCase` for private fields with `_` prefix
- **Do NOT** expose domain entities directly in API controllers

### TypeScript / React

- Use **strict TypeScript** mode
- Use **functional components** with hooks (no class components)
- Use **React Query** for server state management
- Use **Axios** for API calls (configured in `src/api/client.ts`)
- Define **types** in `src/types/` directory
- Use **CSS modules** or scoped CSS files per component
- Naming: `PascalCase` for components, `camelCase` for functions/variables
- Use **arrow functions** for consistency
- **Always** handle loading and error states in data-fetching components

### SQL

- Use **2-space indentation**
- Table names: `PascalCase` singular (e.g., `User`, `Transaction`)
- Column names: `PascalCase`
- Always include appropriate indexes for query performance
- Use **foreign key constraints** for referential integrity

### Terraform

- Use **modules** for reusability
- Separate configurations by environment (`envs/dev`, `envs/prod`)
- Use **variables** with descriptions and validation
- Use **outputs** for inter-module references
- Follow **Azure naming conventions**
- Use **remote state** (configure backend)

## Database Migration Steps

1. Make changes to domain entities in `BudgetBuddy.Domain/Entities/`
2. Create migration:
   ```bash
   cd src/backend
   dotnet ef migrations add MigrationName --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
   ```
3. Review generated migration in `BudgetBuddy.Infrastructure/Migrations/`
4. Apply migration:
   ```bash
   dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
   ```
5. Update seed data if needed

## Definition of Done

A task is considered "done" when:

1. ✅ **Code is written** following conventions above
2. ✅ **Tests are added** (unit tests for business logic, integration tests for APIs)
3. ✅ **Code builds** without errors (`dotnet build` and `npm run build` succeed)
4. ✅ **Tests pass** (`dotnet test` and frontend tests succeed)
5. ✅ **Linting passes** (ESLint for frontend, no warnings)
6. ✅ **Code is formatted** (EditorConfig respected)
7. ✅ **Documentation is updated** (README, inline comments, API docs)
8. ✅ **No secrets committed** (use environment variables, appsettings not committed)
9. ✅ **PR is created** with descriptive title and description
10. ✅ **CI passes** (GitHub Actions workflows succeed)

## Security Guidelines

- **Never commit secrets** or connection strings with real credentials
- Use **environment variables** for sensitive configuration
- Use **Azure Key Vault** references in production Terraform
- Follow **least privilege** principle for database users and Azure identities
- Use **OIDC** for GitHub Actions authentication to Azure (not service principals with secrets)
- Validate all **user inputs** in API controllers
- Use **parameterized queries** (EF Core does this automatically)
- Implement **rate limiting** for public APIs (when deployed)
- Use **HTTPS** only in production
- Regularly update **dependencies** (Dependabot enabled)

## Common Patterns

### Adding a New API Endpoint

1. Create domain entity in `BudgetBuddy.Domain/Entities/`
2. Add DbSet to `BudgetBuddyDbContext.cs`
3. Configure entity in `OnModelCreating`
4. Create migration and apply
5. Create DTO in `BudgetBuddy.Application/DTOs/`
6. Create service interface and implementation in `BudgetBuddy.Application/Services/`
7. Register service in `Program.cs`
8. Create controller in `BudgetBuddy.Api/Controllers/`
9. Add unit tests in `BudgetBuddy.Tests/Unit/`
10. Add integration tests in `BudgetBuddy.Tests/Integration/`

### Adding a New Frontend Page

1. Create component in `src/frontend/src/pages/`
2. Add route in `App.tsx`
3. Create API client function in `src/api/`
4. Define TypeScript types in `src/types/`
5. Use React Query hooks (`useQuery`, `useMutation`)
6. Add CSS file for styles
7. Update navigation in `App.tsx`
8. Add tests (if test infrastructure is set up)

## Copilot Usage Tips

- Use **Copilot Chat** for architectural questions
- Use **inline suggestions** for repetitive code patterns
- Use **Copilot for PRs** to generate PR descriptions
- Reference this file by saying "follow repository custom instructions"
- For area-specific guidance, Copilot will automatically apply path-scoped instructions from `.github/instructions/`

## Important Files to Review

- `src/backend/BudgetBuddy.Api/Program.cs` - API startup configuration
- `src/backend/BudgetBuddy.Infrastructure/Data/BudgetBuddyDbContext.cs` - EF Core configuration
- `src/frontend/src/App.tsx` - Frontend routing and React Query setup
- `docker-compose.yml` - Local development services
- `.devcontainer/devcontainer.json` - Codespaces configuration

## Getting Help

- Check `docs/runbooks/` for operational guides
- Review `docs/architecture.md` for system design
- See `db/README.md` for database documentation
- Consult `infra/terraform/README.md` for infrastructure details
