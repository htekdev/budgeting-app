# BudgetBuddy - GitHub Copilot Instructions

## Project Overview
BudgetBuddy is a **full-stack personal budgeting and cashflow management application** that demonstrates GitHub Copilot capabilities across the entire Software Development Lifecycle (SDLC). This repository showcases:

- **Coding**: Clean architecture with C# backend and TypeScript React frontend
- **Testing**: Unit tests, integration tests, and test-driven development patterns
- **Database Design**: SQL Server schema with EF Core migrations
- **Infrastructure as Code**: Terraform for Azure deployments
- **CI/CD**: GitHub Actions workflows for build, test, deploy
- **Documentation**: Comprehensive docs, ADRs, runbooks, and diagrams
- **Copilot Customization**: Custom instructions, agents, and skills

## Repository Structure

```
/
├── src/
│   ├── backend/           # ASP.NET Core Web API (.NET 8+)
│   │   ├── BudgetBuddy.Api/          # REST API controllers
│   │   ├── BudgetBuddy.Domain/       # Domain entities
│   │   ├── BudgetBuddy.Application/  # Business logic, DTOs
│   │   ├── BudgetBuddy.Infrastructure/  # EF Core, repositories
│   │   └── BudgetBuddy.Tests/        # Unit & integration tests
│   └── frontend/          # React + TypeScript + Vite
│       ├── src/
│       ├── tests/
│       └── Dockerfile
├── db/
│   ├── schema/            # SQL Server schema scripts
│   └── migrations/        # EF Core migrations
├── infra/
│   └── terraform/         # Azure infrastructure as code
│       ├── modules/
│       └── envs/
├── docs/
│   ├── architecture.md
│   ├── decisions/         # Architecture Decision Records
│   ├── runbooks/          # Operational guides
│   └── diagrams/          # Mermaid diagrams
├── .github/
│   ├── workflows/         # GitHub Actions CI/CD
│   ├── copilot-instructions.md  # This file
│   ├── instructions/      # Path-scoped instructions
│   ├── agents/            # Custom agents definitions
│   └── skills/            # Agent skills
└── docker-compose.yml
```

## Build, Test, and Lint Commands

### Backend (ASP.NET Core)

**Location**: `src/backend/`

**Build**:
```bash
cd src/backend
dotnet build
```

**Test**:
```bash
cd src/backend
dotnet test
```

**Run locally**:
```bash
cd src/backend/BudgetBuddy.Api
dotnet run
```

**Run with Docker Compose**:
```bash
docker compose up backend
```

**API Available at**: http://localhost:5000
**Swagger UI**: http://localhost:5000/swagger

### Frontend (React + TypeScript + Vite)

**Location**: `src/frontend/`

**Install dependencies**:
```bash
cd src/frontend
npm install
```

**Lint**:
```bash
cd src/frontend
npm run lint
```

**Test**:
```bash
cd src/frontend
npm test
```

**Build**:
```bash
cd src/frontend
npm run build
```

**Run dev server**:
```bash
cd src/frontend
npm run dev
```

**Run with Docker Compose**:
```bash
docker compose up frontend
```

**App available at**: http://localhost:3000

### Database

**Location**: `db/`

**Apply migrations** (automatic in development):
```bash
cd src/backend
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

**Create new migration**:
```bash
cd src/backend
dotnet ef migrations add MigrationName --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

**SQL Server runs in Docker**:
```bash
docker compose up sqlserver
```

**Connection String** (local): `Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;`

### Terraform

**Location**: `infra/terraform/`

**Format**:
```bash
cd infra/terraform
terraform fmt -recursive
```

**Validate**:
```bash
cd infra/terraform/envs/dev
terraform init
terraform validate
```

**Plan**:
```bash
cd infra/terraform/envs/dev
terraform plan
```

**Apply** (requires Azure credentials):
```bash
cd infra/terraform/envs/dev
terraform apply
```

### Full Stack (Docker Compose)

**Start everything**:
```bash
docker compose up
```

**Start specific services**:
```bash
docker compose up sqlserver backend frontend
```

**Stop all**:
```bash
docker compose down
```

**Clean volumes** (removes database data):
```bash
docker compose down -v
```

## Coding Conventions

### TypeScript/React Frontend

- **Components**: Use functional components with hooks (no class components)
- **Typing**: Strict TypeScript; avoid `any` unless absolutely necessary
- **State Management**: React Query for server state, useState/useContext for local state
- **File Structure**: Group by feature, co-locate tests with components
- **Naming**: 
  - Components: PascalCase (e.g., `AccountList.tsx`)
  - Hooks: camelCase with `use` prefix (e.g., `useAccounts.ts`)
  - Utilities: camelCase (e.g., `formatCurrency.ts`)
- **Imports**: Group and order: React, third-party, local
- **Forms**: Use controlled components with validation
- **API Calls**: Always use React Query hooks
- **Error Handling**: Always handle loading and error states in UI

**Example**:
```typescript
// Good
export const AccountList: React.FC = () => {
  const { data: accounts, isLoading, error } = useAccounts();
  
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return (
    <div>
      {accounts?.map(account => (
        <AccountCard key={account.accountId} account={account} />
      ))}
    </div>
  );
};

// Bad - missing error handling, using any
export const AccountList = () => {
  const [accounts, setAccounts] = useState<any>();
  // ... rest of component without error handling
};
```

### C# Backend

- **Nullable Reference Types**: Enabled; use `?` for nullable and `!` for null-forgiving
- **Async/Await**: Always use async for I/O operations; don't block on async code
- **Dependency Injection**: Constructor injection for all dependencies
- **Logging**: Use `ILogger<T>`; log at appropriate levels (Debug, Info, Warning, Error)
- **Validation**: Use FluentValidation for complex validation
- **Error Handling**: Return `ProblemDetails` for API errors
- **Naming**:
  - Classes: PascalCase
  - Methods: PascalCase
  - Parameters/locals: camelCase
  - Private fields: `_camelCase`
- **Layering**:
  - Domain: Entities, value objects (no dependencies)
  - Application: DTOs, commands, queries, interfaces
  - Infrastructure: EF Core, external services
  - API: Controllers, middleware
- **Testing**: Unit test business logic, integration test APIs with Testcontainers

**Example**:
```csharp
// Good
public class AccountsController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<AccountsController> _logger;

    public AccountsController(
        BudgetBuddyDbContext context,
        ILogger<AccountsController> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts(
        [FromQuery] int userId = 1,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching accounts for user {UserId}", userId);
        
        var accounts = await _context.Accounts
            .Where(a => a.UserId == userId && a.IsActive)
            .ToListAsync(cancellationToken);
            
        return Ok(accounts);
    }
}

// Bad - missing logging, not async, poor error handling
public class AccountsController : ControllerBase
{
    public IActionResult GetAccounts(int userId)
    {
        var accounts = _context.Accounts.Where(a => a.UserId == userId).ToList();
        return Ok(accounts);
    }
}
```

### SQL Database

- **Naming**: 
  - Tables: PascalCase singular (e.g., `Account` not `Accounts`)
  - Columns: PascalCase (e.g., `AccountName`)
  - Indexes: `IX_TableName_ColumnName`
  - Foreign Keys: `FK_ChildTable_ParentTable`
- **Primary Keys**: `TableNameId` (e.g., `AccountId`)
- **Timestamps**: Use `DATETIME2` not `DATETIME`
- **Money**: Use `DECIMAL(18,2)` not `MONEY`
- **Constraints**: Always add check constraints for enums and business rules
- **Indexes**: Add indexes for foreign keys and common query filters
- **Migrations**: Never delete or modify existing migrations; create new ones
- **Breaking Changes**: Require multi-step migrations (add new column, migrate data, drop old column)

**Example**:
```sql
-- Good
CREATE TABLE Transactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT CHK_Amount CHECK (Amount > 0)
);

CREATE INDEX IX_Transactions_AccountId_TransactionDate 
ON Transactions(AccountId, TransactionDate);

-- Bad - wrong types, missing constraints
CREATE TABLE Transactions (
    id INT PRIMARY KEY,
    account_id INT,
    amount MONEY,
    date DATETIME
);
```

### Terraform

- **File Structure**: Separate `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`
- **Naming**: Use lowercase with underscores (e.g., `resource_group_name`)
- **Modules**: Encapsulate related resources; use versioned modules
- **Variables**: Always provide descriptions and validation where possible
- **Secrets**: Never hardcode; use Azure Key Vault or environment variables
- **State**: Use remote state (Azure Storage) in shared environments
- **Formatting**: Always run `terraform fmt` before committing

**Example**:
```hcl
# Good
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-budgetbuddy-${var.environment}-${var.location}"
  location = var.location
  
  tags = var.common_tags
}

# Bad - hardcoded values, no validation
resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "eastus"
}
```

## GitHub Actions Workflows

- **Naming**: Use descriptive names (e.g., `ci.yml`, `cd-production.yml`)
- **Triggers**: Be specific (e.g., `paths` filters for monorepo)
- **Secrets**: Use GitHub Secrets or OIDC; never commit credentials
- **Caching**: Cache dependencies (npm, NuGet) to speed up builds
- **Matrix Builds**: Test across multiple versions if needed
- **Artifacts**: Upload test results and build artifacts
- **Environments**: Use GitHub Environments for deployment approvals

## Definition of Done

Before marking work as complete, ensure:

- [ ] Code builds without errors
- [ ] All tests pass (unit + integration)
- [ ] Code follows conventions outlined above
- [ ] No linting errors
- [ ] Documentation updated (if public APIs changed)
- [ ] Database migrations created (if schema changed)
- [ ] Terraform validated (if infra changed)
- [ ] PR template checklist completed
- [ ] No security vulnerabilities introduced
- [ ] Copilot instructions updated (if workflow changed)

## Copilot Customization

This repository includes extensive Copilot customization:

### Path-Scoped Instructions
Located in `.github/instructions/`, these provide context-specific guidance:
- `general.instructions.md` - applies to all files
- `frontend.instructions.md` - TypeScript/React specific
- `backend.instructions.md` - C# specific
- `terraform.instructions.md` - Infrastructure specific
- `sql.instructions.md` - Database specific
- `workflows.instructions.md` - GitHub Actions specific

### Custom Agents
Located in `.github/agents/`, these are specialized assistants:
- `planner.agent.md` - Task breakdown and planning
- `implementer.agent.md` - Code implementation
- `reviewer.agent.md` - Code review and quality
- `devops.agent.md` - CI/CD and infrastructure
- `data.agent.md` - Database design and queries

### Agent Skills
Located in `.github/skills/`, these are reusable playbooks:
- `api-design/` - REST API design patterns
- `db-migrations/` - Database migration strategies
- `terraform-best-practices/` - Infrastructure patterns
- `github-actions-cicd/` - CI/CD patterns
- `testing-strategy/` - Testing approaches
- `security-review/` - Security best practices
- `budgeting-domain/` - Domain-specific rules
- `reporting-queries/` - Optimized query patterns

## Getting Help

- **Local Development**: See `docs/runbooks/local-dev.md`
- **CI/CD**: See `docs/runbooks/ci-cd.md`
- **Terraform**: See `docs/runbooks/terraform.md`
- **Database**: See `db/README.md`
- **Architecture**: See `docs/architecture.md`
- **Decisions**: See `docs/decisions/` for ADRs

## Quick Start

1. **Clone and start services**:
   ```bash
   git clone <repository>
   cd budgeting-app
   docker compose up
   ```

2. **Access services**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Swagger UI: http://localhost:5000/swagger
   - SQL Server: localhost:1433

3. **Develop locally**:
   - Backend: Use Visual Studio, VS Code, or Rider
   - Frontend: Use VS Code with ESLint/Prettier extensions
   - Database: Use Azure Data Studio or SSMS

## Environment Variables

**Backend** (src/backend/BudgetBuddy.Api/appsettings.json):
- `ConnectionStrings__DefaultConnection` - SQL Server connection string

**Frontend** (.env.local):
- `VITE_API_BASE_URL` - Backend API URL (default: http://localhost:5000)

**Never commit secrets or credentials to version control.**
