# GitHub Copilot Instructions for BudgetBuddy

## Project Overview
BudgetBuddy is a full-stack personal budgeting application demonstrating GitHub Copilot capabilities across the SDLC. The application helps users manage budgets, track expenses, and categorize transactions.

## Technology Stack
- **Backend**: .NET 10 ASP.NET Core Web API with Minimal APIs
- **Frontend**: React 18+ with TypeScript and Vite
- **Database**: SQL Server with Entity Framework Core
- **Infrastructure**: Terraform for Azure, Docker for local development
- **CI/CD**: GitHub Actions
- **Development**: GitHub Codespaces with devcontainer support

## Code Style & Standards

### C# Backend
- Use Minimal APIs pattern (not controllers)
- Follow Clean Architecture: Domain → Infrastructure → API layers
- Use async/await throughout for database operations
- Implement proper error handling with Problem Details (RFC 7807)
- Use Serilog for structured logging
- Apply pagination for list endpoints (default 10 items, max 100)
- Use GUID for entity IDs
- Add XML documentation comments for public APIs
- Follow Microsoft C# coding conventions
- Use required properties with init accessors where appropriate
- Prefer record types for DTOs
- Use FluentValidation for request validation

### TypeScript Frontend
- Use functional components with React Hooks
- Type all component props and state
- Use strict TypeScript configuration
- Generate API client from OpenAPI spec (do not hand-write API calls)
- Use CSS modules or styled-components for styling
- Implement proper error boundaries
- Use React Query for data fetching and caching
- Follow Airbnb React/TypeScript style guide

### Database
- Use Entity Framework Core Code-First approach
- Create migrations for all schema changes
- Seed development data in DbInitializer
- Use proper indexes on foreign keys and frequently queried columns
- Configure cascade delete behavior explicitly
- Use decimal(18,2) for monetary values

### Infrastructure as Code
- Use Terraform for all Azure resources
- Pin provider versions
- Use variables for all configurable values
- Create terraform.tfvars.example (never commit actual .tfvars)
- Add outputs for important resource identifiers
- Use consistent naming convention: budgetbuddy-{env}-{resource}

## Security Practices
- Never commit secrets or connection strings to source control
- Use environment variables for sensitive configuration
- Store secrets in Azure Key Vault (production) or User Secrets (development)
- Implement CORS properly - whitelist specific origins
- Use HTTPS redirection
- Add rate limiting to public endpoints
- Validate all user inputs
- Use parameterized queries (EF Core handles this)
- Implement proper authentication and authorization (JWT Bearer tokens)

## Testing
- Write unit tests for business logic
- Write integration tests for API endpoints
- Maintain minimum 70% code coverage
- Use xUnit for .NET tests
- Use Vitest for frontend tests
- Mock external dependencies
- Test both success and error paths
- Use meaningful test names that describe the scenario

## Documentation
- Keep README.md up to date with setup instructions
- Document all public APIs with XML comments
- Create runbooks for common operations in docs/runbooks/
- Use Mermaid diagrams for architecture documentation
- Document environment variables in .env.example files
- Add inline comments only for complex business logic

## Git Workflow
- Use conventional commits: feat:, fix:, docs:, chore:, test:, refactor:
- Keep commits atomic and focused
- Write descriptive commit messages
- Reference issue numbers in commits when applicable
- Never force push to main or protected branches
- Always rebase feature branches before merging

## Performance Considerations
- Use async/await for I/O operations
- Implement caching where appropriate
- Use pagination for large data sets
- Optimize database queries (avoid N+1 problems)
- Use EF Core Include() for related data
- Implement compression for API responses
- Lazy load large resources on frontend

## Observability
- Log important application events with structured logging
- Include correlation IDs in logs for request tracing
- Use appropriate log levels (Debug, Information, Warning, Error, Fatal)
- Implement health checks for dependencies
- Add metrics for key business operations
- Monitor application performance and errors

## AI-Assisted Development with Copilot
- Use custom agents for specialized tasks (backend, frontend, database, DevOps)
- Reference agent skills for common operations
- Use workspace context commands to understand code structure
- Ask for explanations before making changes to unfamiliar code
- Review generated code for security implications
- Test AI-generated code thoroughly
- Use /fix for resolving issues
- Use /doc for generating documentation

## Common Patterns

### Adding a New API Endpoint
1. Create or update domain entity in BudgetBuddy.Domain/Entities
2. Update DbContext if new entity
3. Create migration: `dotnet ef migrations add <MigrationName>`
4. Add endpoint in Program.cs with proper tags and names
5. Add validation if needed
6. Update frontend API client: `npm run generate:client`
7. Create React component/hook to consume endpoint
8. Add tests for endpoint

### Database Changes
1. Modify entity in Domain layer
2. Update DbContext configuration if relationships change
3. Create migration: `dotnet ef migrations add <MigrationName>`
4. Review generated migration
5. Apply migration: `dotnet ef database update`
6. Update seed data if needed

### Adding New Features
1. Check existing patterns in the codebase
2. Follow Clean Architecture principles
3. Write tests first (TDD) when possible
4. Update documentation
5. Create PR with clear description
6. Request code review

## Error Handling Examples

### Backend
```csharp
app.MapGet("/api/budgets/{id:guid}", async (Guid id, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets.FindAsync(id);
    return budget is not null ? Results.Ok(budget) : Results.NotFound();
})
.WithName("GetBudgetById")
.WithTags("Budgets");
```

### Frontend
```typescript
const { data, error, isLoading } = useQuery({
  queryKey: ['budget', id],
  queryFn: () => api.getBudget(id),
});

if (error) return <ErrorMessage error={error} />;
if (isLoading) return <Loading />;
```

## Build & Deployment
- Backend builds with `dotnet build`
- Frontend builds with `npm run build`
- Run locally with docker-compose up
- Deploy to Azure with GitHub Actions workflows
- Always test in development before production deployment

## Resources
- Architecture docs: docs/architecture/
- Runbooks: docs/runbooks/
- API documentation: http://localhost:5000/swagger (when running locally)
