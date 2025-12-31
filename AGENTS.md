# Autonomous Coding Agent Guide

This document provides guidance for autonomous coding agents working in the BudgetBuddy repository. Follow these guidelines to work effectively and maintain code quality.

## Overview

BudgetBuddy is a full-stack budgeting application built to demonstrate GitHub Copilot capabilities. It consists of:
- **Backend**: ASP.NET Core Web API with EF Core
- **Frontend**: React + TypeScript + Vite
- **Database**: SQL Server with schema-first design
- **Infrastructure**: Terraform for Azure
- **CI/CD**: GitHub Actions workflows

## How to Work in This Repository

### 1. Understand the Task

Before making any changes:
- Read the issue or PR description carefully
- Identify which components are affected (frontend, backend, database, infrastructure)
- Check if there are related Architecture Decision Records (ADRs) in `docs/decisions/`
- Review relevant custom instructions in `.github/instructions/`

### 2. Build and Test Locally

**Always verify the current state before making changes:**

```bash
# Backend
cd src/backend
dotnet build
dotnet test

# Frontend
cd src/frontend
npm install
npm run lint
npm test
npm run build

# Full stack
docker compose up
```

**Expected outcomes**:
- All builds succeed
- All tests pass
- Docker Compose starts all services without errors

### 3. Make Minimal, Focused Changes

**Principles**:
- Change only what's necessary to address the task
- Prefer small, incremental changes over large rewrites
- Keep PRs focused on a single concern
- Update tests alongside code changes
- Update documentation if APIs or workflows change

**Don't**:
- Refactor unrelated code
- Change formatting/style without explicit permission
- Add new dependencies without justification
- Break existing functionality
- Commit secrets or credentials

### 4. Follow Repository Conventions

All coding conventions are documented in `.github/copilot-instructions.md`. Key principles:

**Backend (C#)**:
- Async/await for I/O operations
- Constructor dependency injection
- Structured logging with `ILogger<T>`
- ProblemDetails for API errors
- FluentValidation for complex validation
- Clean Architecture layering (Domain → Application → Infrastructure → API)

**Frontend (TypeScript/React)**:
- Functional components with hooks
- React Query for server state
- Strict TypeScript (avoid `any`)
- Co-locate tests with components
- Handle loading and error states

**Database**:
- EF Core Code-First with migrations
- Schema scripts in `db/schema/` are source of truth for understanding
- Never modify existing migrations
- Add indexes for common query patterns

**Infrastructure**:
- Modular Terraform code
- Remote state for shared environments
- Secrets via Azure Key Vault or environment variables

### 5. Testing Strategy

**Backend Tests**:
```bash
cd src/backend
dotnet test
```

Test types:
- **Unit tests**: Domain logic, business rules, calculations
- **Integration tests**: API endpoints with Testcontainers for SQL Server

**Frontend Tests**:
```bash
cd src/frontend
npm test
```

Test types:
- **Component tests**: UI components in isolation
- **Integration tests**: User flows and API interactions

**When to write tests**:
- Always for new business logic
- Always for bug fixes (test should fail before fix, pass after)
- For API endpoints (integration tests)
- For complex UI components

### 6. Database Migrations

**Creating migrations**:
```bash
cd src/backend
dotnet ef migrations add MigrationName \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api
```

**Applying migrations** (automatic in development, manual in production):
```bash
dotnet ef database update \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api
```

**Migration rules**:
- One migration per logical schema change
- Never modify existing migrations after they're merged
- For breaking changes, use multi-step migrations
- Update seed data if needed
- Test both up and down migrations

### 7. CI/CD Workflows

All workflows are in `.github/workflows/`:
- `ci.yml` - Build, lint, test on every PR
- `terraform.yml` - Validate infrastructure changes
- `cd.yml` - Deploy to environments
- `codeql.yml` - Security scanning

**Before pushing**:
- Ensure all local builds and tests pass
- Run linters
- Verify Docker Compose works

**CI failures**:
- Check the workflow logs
- Reproduce the failure locally
- Fix and push again

### 8. Git Workflow

**Branch naming**:
- `feature/short-description` - New features
- `fix/short-description` - Bug fixes
- `docs/short-description` - Documentation only
- `refactor/short-description` - Code refactoring

**Commit messages**:
- Use present tense ("Add feature" not "Added feature")
- Be descriptive but concise
- Reference issue numbers (#123)

**Example**:
```
Add transaction CSV import endpoint

- Implement POST /api/v1/transactions/import
- Add CSV validation logic
- Add unit tests for import service
- Update API documentation

Fixes #42
```

### 9. Documentation Updates

**When to update docs**:
- API changes → Update Swagger docs and `docs/api/openapi-notes.md`
- New environment variables → Update `.github/copilot-instructions.md`
- Architecture decisions → Add ADR in `docs/decisions/`
- New commands or workflows → Update relevant runbook in `docs/runbooks/`

**Documentation locations**:
- `README.md` - Overview, quick start
- `docs/architecture.md` - System architecture
- `docs/decisions/` - Architecture Decision Records (ADRs)
- `docs/runbooks/` - Operational guides
- `db/README.md` - Database documentation
- `.github/copilot-instructions.md` - Coding guidelines

### 10. Security Guardrails

**Never**:
- Commit secrets, API keys, passwords, or certificates
- Hardcode connection strings or URLs
- Disable security features without justification
- Use SQL string concatenation (use parameterized queries)
- Accept unvalidated user input

**Always**:
- Use environment variables for configuration
- Validate all inputs (client and server side)
- Use parameterized queries or ORMs (we use EF Core)
- Sanitize data for display (prevent XSS)
- Log security events (authentication, authorization failures)

**Example placeholders for secrets**:
```bash
# .env.example
ConnectionStrings__DefaultConnection=Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YOUR_PASSWORD_HERE;

# Actual .env (gitignored)
ConnectionStrings__DefaultConnection=Server=localhost;Database=BudgetBuddy;User Id=sa;Password=ActualPassword123!;
```

## Copilot Customization Resources

### Custom Instructions

Located in `.github/instructions/`:
- `general.instructions.md` - Applies to all files
- `frontend.instructions.md` - TypeScript/React rules
- `backend.instructions.md` - C# rules
- `terraform.instructions.md` - Infrastructure rules
- `sql.instructions.md` - Database rules
- `workflows.instructions.md` - GitHub Actions rules

**How they work**: Instructions apply based on file path globs. Check the YAML frontmatter in each file.

### Custom Agents

Located in `.github/agents/`:
- `planner.agent.md` - Breaks down tasks into steps
- `implementer.agent.md` - Implements code changes
- `reviewer.agent.md` - Reviews code for quality and security
- `devops.agent.md` - Manages CI/CD and infrastructure
- `data.agent.md` - Handles database design and queries

**How to use**: Agents are specialized assistants. Invoke them for domain-specific tasks.

### Agent Skills

Located in `.github/skills/`:
- `api-design/` - REST API patterns
- `db-migrations/` - Safe migration strategies
- `terraform-best-practices/` - Infrastructure patterns
- `github-actions-cicd/` - CI/CD workflows
- `testing-strategy/` - Testing approaches
- `security-review/` - Security checklists
- `budgeting-domain/` - Domain rules (budgets, recurring, goals)
- `reporting-queries/` - Optimized SQL patterns

**How they work**: Skills are playbooks. Follow the steps in each SKILL.md file.

## Nearest AGENTS.md Precedence

This file is located at the repository root. If you find an AGENTS.md file in a subdirectory (e.g., `src/backend/AGENTS.md`), that file takes precedence for files in that directory and below.

**Current structure**:
- `/AGENTS.md` - This file (root level, applies to entire repository)

## Common Tasks Quick Reference

### Add a new API endpoint
```bash
# 1. Add DTO in Application layer
# 2. Add method in controller
# 3. Update Swagger documentation
# 4. Write integration test
# 5. Build and test

cd src/backend
dotnet build
dotnet test
```

### Add a new React component
```bash
# 1. Create component file
# 2. Write component with proper typing
# 3. Add tests
# 4. Update parent component

cd src/frontend
npm run lint
npm test
npm run build
```

### Add a database migration
```bash
# 1. Update entities in Domain layer
# 2. Update DbContext if needed
# 3. Generate migration

cd src/backend
dotnet ef migrations add MigrationName \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api

# 4. Review generated migration
# 5. Test migration up and down
```

### Add infrastructure resource
```bash
# 1. Add resource to appropriate module
# 2. Add variables if needed
# 3. Add outputs if needed
# 4. Format and validate

cd infra/terraform
terraform fmt -recursive
cd envs/dev
terraform init
terraform validate
terraform plan
```

### Update documentation
```bash
# 1. Identify what changed
# 2. Update relevant docs:
#    - README.md for overview changes
#    - copilot-instructions.md for workflow changes
#    - architecture.md for design changes
#    - Add ADR for significant decisions
# 3. Update diagrams if architecture changed
```

## Troubleshooting

### Build Failures

**Backend won't build**:
```bash
cd src/backend
dotnet clean
dotnet restore
dotnet build
```

**Frontend won't build**:
```bash
cd src/frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Test Failures

**Check test output**:
```bash
cd src/backend
dotnet test --logger:"console;verbosity=detailed"

cd src/frontend
npm test -- --verbose
```

### Docker Compose Issues

**Services won't start**:
```bash
# Stop and remove everything
docker compose down -v

# Rebuild images
docker compose build --no-cache

# Start again
docker compose up
```

**Database connection issues**:
- Check SQL Server is running: `docker compose ps`
- Verify connection string in `appsettings.json`
- Check SQL Server logs: `docker compose logs sqlserver`

### Migration Issues

**Migration fails**:
```bash
# Rollback to previous migration
dotnet ef database update PreviousMigrationName \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api

# Remove bad migration
dotnet ef migrations remove \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api

# Create new migration
dotnet ef migrations add FixedMigration \
  --project BudgetBuddy.Infrastructure \
  --startup-project BudgetBuddy.Api
```

## Quality Checklist

Before submitting work:

- [ ] Code builds without errors
- [ ] All tests pass
- [ ] No linting errors
- [ ] Docker Compose runs successfully
- [ ] Documentation updated
- [ ] No secrets committed
- [ ] PR description is clear and complete
- [ ] Breaking changes are documented
- [ ] Database migrations tested
- [ ] API changes have integration tests

## Getting Help

If you're unsure about something:
1. Check `.github/copilot-instructions.md` for conventions
2. Review relevant Agent Skills in `.github/skills/`
3. Check ADRs in `docs/decisions/` for architectural context
4. Look at existing code for patterns
5. Ask for clarification in the issue or PR

## Summary

**Golden Rules**:
1. **Test first**: Ensure everything works before changing it
2. **Small changes**: Keep changes focused and minimal
3. **Follow conventions**: Use established patterns
4. **Update docs**: Keep documentation in sync
5. **No secrets**: Never commit credentials
6. **Verify locally**: Test before pushing
7. **Clean commits**: Write clear commit messages
8. **Respect precedence**: Use nearest AGENTS.md if available

By following these guidelines, you'll work effectively in this repository and maintain the quality that makes BudgetBuddy a great example of software craftsmanship with GitHub Copilot.
