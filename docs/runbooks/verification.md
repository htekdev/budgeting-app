# Verification & Research Alignment

This document tracks authoritative sources used, alignment notes, and verification procedures for BudgetBuddy.

## Research Alignment Notes

### Custom Agents YAML Schema
**Source:** 
- https://docs.github.com/copilot/reference/custom-agents-configuration
- https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/

**Key Constraints:**
- Files placed in `.github/agents/*.agent.md`
- YAML frontmatter properties: `name` (string), `description` (string, required), `target` (string), `tools` (list), `infer` (boolean), `mcp-servers` (object), `metadata` (key-value pairs)
- Tools can be restricted to specific capabilities (e.g., `["search", "edit", "read"]`) or all (`["*"]`)
- Markdown instructions follow the YAML frontmatter

**Deviations:** None - following official schema exactly

**Future Tasks:** Custom agents will guide code generation for backend, frontend, database, and DevOps tasks

---

### Instructions Files with applyTo YAML Frontmatter
**Source:**
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- https://github.blog/changelog/2025-07-23-github-copilot-coding-agent-now-supports-instructions-md-custom-instructions/
- https://github.blog/ai-and-ml/unlocking-the-full-power-of-copilot-code-review-master-your-instructions-files/

**Key Constraints:**
- Files placed in `.github/instructions/*.instructions.md`
- YAML frontmatter properties: `description` (string), `applyTo` (glob pattern or comma-separated patterns), `excludeAgent` (optional)
- Glob patterns use standard syntax: `**/*.ts`, `src/backend/**/*.cs`, etc.
- Repository-wide instructions in `.github/copilot-instructions.md` (no frontmatter needed)

**Deviations:** None - following official schema exactly

**Future Tasks:** Instructions will provide context-specific guidance for different file types and project areas

---

### .NET 10 ASP.NET Core Web API Best Practices
**Source:**
- https://learn.microsoft.com/en-us/aspnet/core/fundamentals/best-practices?view=aspnetcore-10.0
- https://www.telerik.com/blogs/whats-new-apis-net-10-real-improvements
- https://www.syncfusion.com/blogs/post/performance-tuning-in-aspnetcore-2026

**Key Constraints:**
- Use async/await throughout (avoid blocking calls)
- Implement pagination for large collections
- Use built-in validation for Minimal APIs
- Document with OpenAPI/Swagger
- Centralized error handling with Problem Details (RFC 7807)
- Modern auth with JWT bearer tokens
- Built-in metrics with OpenTelemetry
- Clean Architecture: Presentation → Application → Domain → Infrastructure layers
- Use `MapStaticAssets` for static file optimization
- Implement rate limiting middleware

**Deviations:** None - implementing all best practices

**Future Tasks:** Backend API will implement all these best practices for enterprise-grade quality

---

### Devcontainer Configuration
**Source:**
- https://code.visualstudio.com/remote/advancedcontainers/change-default-source-mount
- https://containers.dev/implementors/json_schema/

**Key Constraints:**
- File located at `.devcontainer/devcontainer.json`
- Required properties: `image` or `build`, `features`, `customizations`
- Workspace mount behavior: default is bind mount to `/workspaces/<repo-name>`
- postCreateCommand, postStartCommand for initialization
- Extensions configured under `customizations.vscode.extensions`

**Deviations:** None - using standard devcontainer schema

**Future Tasks:** Devcontainer will provide consistent development environment with .NET 10, Node.js, SQL Server

---

### OpenAPI to TypeScript Client Generation
**Source:**
- https://www.npmjs.com/package/swagger-typescript-api
- https://github.com/acacode/swagger-typescript-api

**Key Constraints:**
- Generates TypeScript client from OpenAPI 3.0 spec
- Configurable via CLI or programmatic API
- Supports axios, fetch API clients
- Type-safe request/response models

**Deviations:** None - using standard generation approach

**Future Tasks:** Frontend will consume auto-generated TypeScript client for type-safe API calls

---

### remark-validate-links (Documentation Validation)
**Source:**
- https://www.npmjs.com/package/remark-validate-links
- https://github.com/remarkjs/remark-validate-links

**Key Constraints:**
- Validates internal links and heading references in Markdown
- Checks file existence and anchor validity
- Can be integrated into CI/CD pipeline
- Configurable to skip external links

**Deviations:** None - using as documentation quality gate

**Future Tasks:** CI workflow will validate all documentation links before merge

---

## Verification Procedures

### Local Development Verification

#### Prerequisites Check
```bash
# Check .NET 10 SDK
dotnet --version  # Should output 10.x.x

# Check Node.js (v20+)
node --version    # Should output v20.x.x or higher

# Check Docker
docker --version
docker-compose --version
```

#### Backend Verification
```bash
# Navigate to backend
cd src/backend/BudgetBuddy.API

# Restore dependencies
dotnet restore

# Build
dotnet build

# Run tests
dotnet test

# Run API locally
dotnet run

# Expected output: API running on https://localhost:5001
# OpenAPI spec available at https://localhost:5001/swagger
```

#### Frontend Verification
```bash
# Navigate to frontend
cd src/frontend

# Install dependencies
npm install

# Generate TypeScript client from OpenAPI spec
npm run generate:client

# Run linter
npm run lint

# Run tests
npm test

# Start dev server
npm run dev

# Expected output: Frontend running on http://localhost:3000
```

#### Database Verification
```bash
# Start SQL Server container
docker-compose up -d sqlserver

# Wait for SQL Server to be ready (30 seconds)
sleep 30

# Apply migrations
cd src/backend/BudgetBuddy.API
dotnet ef database update

# Expected output: Migration applied successfully
```

#### Full Stack Integration
```bash
# Start all services
docker-compose up -d

# Wait for services to start (60 seconds)
sleep 60

# Check API health
curl http://localhost:5000/health

# Expected output: {"status":"Healthy"}
```

### GitHub Codespaces Verification

```bash
# After Codespace creation, postCreateCommand runs automatically
# Verify services are running:

# Check API
curl http://localhost:5000/health

# Check frontend dev server
curl http://localhost:3000

# Run backend tests
cd src/backend/BudgetBuddy.API && dotnet test

# Run frontend tests
cd src/frontend && npm test
```

### CI/CD Verification

#### GitHub Actions Workflows
```bash
# Workflows are triggered automatically on push/PR

# Expected workflows:
# - .github/workflows/backend-ci.yml (build, test, lint)
# - .github/workflows/frontend-ci.yml (build, test, lint)
# - .github/workflows/security-scan.yml (CodeQL, dependency review)
# - .github/workflows/docs-validation.yml (link checker)
# - .github/workflows/terraform-validate.yml (IaC validation)

# All workflows should pass with green checkmarks
```

### Copilot Customization Verification

#### Instructions Files
```bash
# Validate instructions file frontmatter
npm run validate:instructions

# Expected output: All instruction files valid
```

#### Custom Agents
```bash
# Validate agent YAML schema
npm run validate:agents

# Expected output: All agent files valid
```

#### Skills
```bash
# Validate skill definitions
npm run validate:skills

# Expected output: All skill files valid
```

### Documentation Verification

```bash
# Validate all markdown links
npm run validate:docs

# Expected output: No broken links found
```

### Infrastructure Verification

```bash
# Navigate to Terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Expected output: Success! The configuration is valid.

# Plan (dry-run)
terraform plan -var-file="terraform.tfvars.example"

# Expected output: Plan shows resources to be created
```

### Self-Audit Command

```bash
# Run comprehensive self-audit
npm run self:audit

# This command runs:
# - Backend tests
# - Frontend tests
# - Linting checks
# - Security scans
# - Documentation validation
# - Copilot customization validation
# - Infrastructure validation

# Expected output: All checks PASS
```

## Manual Verification Checklist

- [ ] Clone fresh repository
- [ ] Open in GitHub Codespaces
- [ ] Verify postCreateCommand completes successfully
- [ ] Backend API starts and serves OpenAPI spec
- [ ] Frontend starts and connects to backend
- [ ] Database migrations apply successfully
- [ ] Create a budget via UI
- [ ] Add transactions to budget
- [ ] View budget summary
- [ ] All CI workflows pass on PR
- [ ] Custom agents appear in Copilot interface
- [ ] Instructions files provide context in appropriate files
- [ ] Terraform validates successfully
- [ ] Documentation has no broken links

## Success Criteria

All verification procedures must pass for the project to be considered complete:
- ✅ All automated tests pass
- ✅ All linters report no errors
- ✅ All security scans show no critical vulnerabilities
- ✅ Documentation validation passes
- ✅ Copilot customization files validate successfully
- ✅ Infrastructure code validates successfully
- ✅ Manual verification checklist completed
- ✅ Self-audit command returns PASS for all checks
