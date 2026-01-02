# GitHub Copilot Instructions for BudgetBuddy

## Project Overview
BudgetBuddy is a full-stack budgeting application built with:
- **Frontend**: React + TypeScript + Vite
- **Backend**: ASP.NET Core 10 Web API + Entity Framework Core
- **Database**: SQL Server
- **Infrastructure**: Azure (Terraform), Docker Compose for local dev
- **CI/CD**: GitHub Actions

## Architecture Principles
- Follow Clean Architecture patterns
- Use Repository pattern for data access
- Implement SOLID principles
- Maintain clear separation of concerns

## Code Style Guidelines

### C# Backend
- Use C# 13 features and modern syntax
- Follow Microsoft naming conventions (PascalCase for public members, camelCase for private)
- Use record types for DTOs
- Implement async/await patterns consistently
- Use dependency injection for all services
- Add XML documentation comments for public APIs
- Use structured logging with ILogger<T>
- Handle exceptions with proper error responses

### TypeScript Frontend
- Use TypeScript strict mode
- Follow React best practices and hooks patterns
- Use functional components exclusively
- Implement proper error boundaries
- Use custom hooks for reusable logic
- Follow ESLint and Prettier configurations
- Use descriptive variable and function names

## Testing Standards
- Write unit tests for business logic
- Use xUnit for C# tests
- Use Jest/Vitest for TypeScript tests
- Aim for >80% code coverage
- Write integration tests for API endpoints

## Security Guidelines
- Never commit secrets or API keys
- Use environment variables for configuration
- Implement input validation on all endpoints
- Use parameterized queries to prevent SQL injection
- Implement CORS properly
- Use HTTPS in production
- Implement rate limiting for APIs

## Database Conventions
- Use Entity Framework migrations for schema changes
- Name migrations descriptively
- Include seed data for development
- Use proper foreign key relationships
- Index frequently queried columns

## API Design
- Follow RESTful conventions
- Use proper HTTP verbs (GET, POST, PUT, DELETE)
- Return appropriate status codes
- Include meaningful error messages
- Version APIs when making breaking changes
- Document all endpoints with Swagger/OpenAPI

## Git Workflow
- Use conventional commits (feat:, fix:, docs:, etc.)
- Create feature branches from main
- Keep commits focused and atomic
- Write descriptive commit messages
- Squash commits when merging PRs

## Performance Considerations
- Use async/await for I/O operations
- Implement pagination for large datasets
- Use appropriate caching strategies
- Optimize database queries
- Minimize bundle sizes for frontend

## Accessibility
- Use semantic HTML
- Include ARIA labels where appropriate
- Ensure keyboard navigation works
- Maintain proper contrast ratios
- Test with screen readers

When generating code, always consider:
1. Is this code maintainable?
2. Is it properly tested?
3. Does it follow the established patterns?
4. Is it secure?
5. Is it documented?
