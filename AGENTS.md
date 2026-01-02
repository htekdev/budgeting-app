# BudgetBuddy Project Agent Instructions

## Project Context

You are working on BudgetBuddy, a full-stack personal finance and budgeting application.

### Technology Stack
- **Backend**: ASP.NET Core Web API with .NET 10
- **Frontend**: React 18+ with TypeScript (strict mode)
- **Database**: SQL Server (containerized)
- **Infrastructure**: Docker Compose, Terraform (Azure)
- **CI/CD**: GitHub Actions

### Project Structure
```
budgeting-app/
├── backend/              # .NET 10 Web API
├── frontend/             # React + TypeScript
├── terraform/            # Infrastructure as Code
├── .devcontainer/        # Dev Container config
├── .github/              # GitHub configs
├── .verification/        # Verification scripts
└── docker-compose.yml    # Local development
```

## Core Responsibilities

### When Making Code Changes
1. Always follow the verification-first approach
2. Ensure changes align with documented criteria
3. Run appropriate verification scripts before committing
4. Maintain consistency with existing code patterns

### Development Workflow
1. Understand the requirement thoroughly
2. Check existing patterns in the codebase
3. Implement minimal, focused changes
4. Write or update tests as needed
5. Run verification scripts
6. Document significant changes

### Code Quality Standards
- Follow SOLID principles
- Write self-documenting code
- Add comments for complex logic only
- Ensure proper error handling
- Maintain high test coverage

### Security First
- Never commit secrets or credentials
- Validate all user inputs
- Use parameterized queries
- Implement proper authentication/authorization
- Follow OWASP security guidelines

### Performance Considerations
- Use async/await for I/O operations
- Implement proper caching strategies
- Optimize database queries
- Minimize bundle sizes in frontend
- Use lazy loading where appropriate

## Domain Knowledge

### Budget Management Features
- **Budgets**: User-defined spending limits by category
- **Transactions**: Income and expenses tracking
- **Categories**: Customizable expense/income categories
- **Reports**: Spending analysis and visualizations
- **Goals**: Savings goals and progress tracking

### Business Rules
- All monetary amounts use decimal type
- Transactions belong to categories
- Budgets are time-bound (monthly/yearly)
- Users can only access their own data
- Soft delete for data retention

## Communication

### Error Messages
- Be clear and actionable
- Include context about what went wrong
- Suggest how to fix the issue
- Never expose internal system details

### Logging
- Log all errors with full context
- Use structured logging
- Include correlation IDs for tracing
- Log performance metrics for slow operations

### Documentation
- Update README for setup changes
- Document API endpoints with OpenAPI
- Keep architecture docs current
- Document breaking changes

## Testing Strategy

### Unit Tests
- Test business logic in isolation
- Mock external dependencies
- Use descriptive test names
- Cover edge cases and error paths

### Integration Tests
- Test API endpoints end-to-end
- Use test database
- Clean up test data after runs
- Test authentication/authorization

### Frontend Tests
- Test user interactions
- Test component behavior
- Mock API responses
- Test error handling

## Deployment

### Environment Configuration
- Use environment variables for config
- Never hardcode environment-specific values
- Document all required variables
- Provide sensible defaults where safe

### Database Migrations
- Always use EF Core migrations
- Test migrations in both directions
- Never modify applied migrations
- Backup database before major changes

### Docker Best Practices
- Use multi-stage builds
- Minimize image layers
- Use .dockerignore
- Don't run as root user
- Health check all services

## Troubleshooting Guide

### Common Issues
1. **Connection Issues**: Check connection strings and network
2. **Authentication Failures**: Verify JWT configuration
3. **Database Errors**: Check migrations and schema
4. **CORS Issues**: Verify CORS policy in backend
5. **Build Failures**: Check dependency versions

### Debug Process
1. Check logs first
2. Verify configuration
3. Test in isolation
4. Use debugger breakpoints
5. Check for recent changes

## Repository Maintenance

### Before Committing
- Run relevant verification scripts
- Ensure all tests pass
- Format code consistently
- Update documentation as needed

### Pull Request Guidelines
- Keep PRs focused and small
- Write descriptive PR descriptions
- Link to related issues
- Address review feedback promptly
- Ensure CI checks pass

### Code Review Focus
- Security vulnerabilities
- Performance implications
- Test coverage
- Code maintainability
- Documentation completeness
