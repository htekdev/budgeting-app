# GitHub Copilot Instructions for BudgetBuddy

## Project Overview
BudgetBuddy is a full-stack budgeting application built with ASP.NET Core Web API backend (.NET 10) and React + TypeScript frontend.

## General Coding Standards

### Code Style
- Use clear, descriptive variable and function names
- Follow existing code formatting and style in the file
- Add comments only for complex logic or non-obvious decisions
- Keep functions small and focused on a single responsibility

### Security
- Never hardcode passwords, API keys, or secrets in source code
- Always use environment variables or configuration for sensitive data
- Use parameterized queries to prevent SQL injection
- Validate and sanitize all user inputs
- Use HTTPS for all external communications
- Store passwords using secure hashing (bcrypt, Argon2)

### Testing
- Write unit tests for all business logic
- Aim for at least 80% code coverage
- Use meaningful test names that describe what is being tested
- Follow Arrange-Act-Assert pattern in tests

### Documentation
- Document public APIs with XML comments (.NET) or JSDoc (TypeScript)
- Keep README.md up to date with setup instructions
- Document environment variables and configuration requirements
- Include examples in API documentation

## Backend (.NET 10)

### Framework & Conventions
- Use ASP.NET Core Web API with .NET 10
- Follow REST API conventions for endpoints
- Use async/await for all I/O operations
- Implement dependency injection for services
- Use Entity Framework Core for database access

### Code Structure
- Controllers inherit from ControllerBase
- Use [ApiController] and [Route] attributes
- Return appropriate HTTP status codes
- Use DTOs for request/response models
- Implement repository pattern for data access

### Error Handling
- Use global exception handling middleware
- Return consistent error response format
- Log all exceptions with appropriate context
- Never expose internal error details to clients

### Database
- Use Entity Framework Core Code First approach
- Always use migrations for database changes
- Use proper indexing for frequently queried fields
- Implement soft deletes where appropriate

## Frontend (React + TypeScript)

### Framework & Tools
- Use React 18+ with functional components and hooks
- Use TypeScript strict mode
- Use Vite for build tooling
- Use React Router for navigation

### Component Standards
- Prefer functional components over class components
- Use hooks for state management (useState, useEffect, useContext)
- Keep components small and focused
- Extract reusable logic into custom hooks
- Use proper TypeScript typing for all props and state

### State Management
- Use React Context for global state when needed
- Keep state as local as possible
- Consider React Query for server state management
- Use proper TypeScript interfaces for all state shapes

### Styling
- Use consistent styling approach (CSS modules or styled-components)
- Follow responsive design principles
- Use semantic HTML elements
- Ensure accessibility (ARIA attributes, keyboard navigation)

### Performance
- Use React.memo for expensive components
- Implement proper key props in lists
- Use lazy loading for routes and large components
- Optimize bundle size

## API Integration

### Backend API Design
- Use RESTful conventions (GET, POST, PUT, DELETE)
- Version APIs appropriately (e.g., /api/v1/)
- Implement proper CORS configuration
- Use appropriate HTTP status codes
- Document APIs with OpenAPI/Swagger

### Frontend API Calls
- Use consistent API client (axios or fetch)
- Implement proper error handling
- Show loading states during API calls
- Cache responses when appropriate
- Handle authentication tokens securely

## Docker & DevOps

### Containerization
- Use official base images
- Implement multi-stage builds for optimization
- Never include secrets in Docker images
- Use .dockerignore to exclude unnecessary files
- Document all required environment variables

### Docker Compose
- Define all services with health checks
- Use named volumes for data persistence
- Configure proper networking between services
- Set resource limits appropriately

## Infrastructure as Code

### Terraform
- Use variables for all configurable values
- Never hardcode secrets in .tf files
- Use remote backend for state management
- Tag all resources consistently
- Use modules for reusable components
- Pin provider versions

## CI/CD

### GitHub Actions
- Run builds and tests on all pull requests
- Use caching to speed up builds
- Run security scanning on dependencies
- Separate CI and CD concerns
- Use GitHub secrets for sensitive data

## Git Workflow

### Commits
- Write clear, descriptive commit messages
- Keep commits focused on single changes
- Reference issue numbers when applicable

### Branches
- Use descriptive branch names
- Keep branches short-lived
- Rebase to keep history clean when appropriate

### Pull Requests
- Provide clear description of changes
- Include screenshots for UI changes
- Ensure all tests pass before requesting review
- Address review comments promptly
