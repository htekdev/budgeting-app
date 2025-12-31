# ADR-0001: Overall Architecture and Technology Stack

## Status

Accepted

## Context

We need to build a full-stack budgeting application that showcases GitHub Copilot capabilities across the entire SDLC. The application must demonstrate:

- Modern web development practices
- Clean architecture principles
- Infrastructure as Code
- CI/CD automation
- Multiple Copilot features (custom instructions, agents, skills)

## Decision

We have decided to use the following architecture and technology stack:

### Frontend
- **React 18** with **TypeScript**: Modern, type-safe UI development
- **Vite**: Fast build tool with HMR
- **React Query**: Declarative server state management
- **React Router**: Client-side routing
- **Axios**: HTTP client with interceptors

**Rationale**: React is widely adopted, has excellent tooling, and TypeScript adds type safety. React Query simplifies data fetching and caching.

### Backend
- **ASP.NET Core 8**: Modern, high-performance web framework
- **Clean Architecture**: Domain, Application, Infrastructure, API layers
- **Entity Framework Core**: Code-first ORM
- **SQL Server**: Robust relational database

**Rationale**: ASP.NET Core is enterprise-grade, cross-platform, and has excellent tooling. Clean Architecture ensures testability and maintainability.

### Database
- **SQL Server 2022**: Primary datastore
- **Entity Framework Core Migrations**: Schema version control
- Code-first approach with explicit configuration

**Rationale**: SQL Server is industry-standard, well-supported, and integrates seamlessly with EF Core.

### Infrastructure
- **Docker Compose**: Local development
- **Terraform**: Infrastructure as Code for Azure
- **Azure Container Apps**: Serverless container hosting
- **Azure SQL Database**: Managed database service

**Rationale**: Containerization ensures consistency across environments. Terraform provides declarative infrastructure management. Azure offers PaaS services that reduce operational overhead.

### DevOps
- **GitHub Actions**: CI/CD pipelines
- **Dependabot**: Dependency updates
- **CodeQL**: Security scanning
- **GitHub Codespaces**: Cloud development environments

**Rationale**: Native GitHub integration, no external dependencies, excellent developer experience.

## Consequences

### Positive

- Modern, maintainable codebase
- Type safety reduces bugs
- Clean Architecture enables testing
- Infrastructure as Code is repeatable
- Automated CI/CD improves quality
- Excellent developer experience

### Negative

- Learning curve for Clean Architecture
- Entity Framework can have performance implications at scale
- Azure costs for cloud resources
- Terraform state management requires setup

### Neutral

- Multiple languages (C#, TypeScript, HCL)
- Requires Azure subscription for deployment
- Docker required for local development

## Alternatives Considered

### Frontend Alternatives

1. **Next.js**: More opinionated, server-side rendering
   - Rejected: Adds complexity for this demo
   
2. **Vue.js**: Similar to React
   - Rejected: Less industry adoption

3. **Angular**: Full framework
   - Rejected: Steeper learning curve

### Backend Alternatives

1. **Node.js + Express**: JavaScript full-stack
   - Rejected: Wanted to demonstrate polyglot capabilities
   
2. **Python + FastAPI**: Modern Python framework
   - Rejected: ASP.NET Core has better enterprise adoption

3. **Java + Spring Boot**: Enterprise standard
   - Rejected: More verbose than C#

### Database Alternatives

1. **PostgreSQL**: Open-source alternative
   - Rejected: SQL Server integrates better with Azure

2. **MongoDB**: Document database
   - Rejected: Relational model fits budgeting domain better

### Infrastructure Alternatives

1. **AWS**: Alternative cloud provider
   - Rejected: Chose Azure for consistency

2. **Kubernetes**: Container orchestration
   - Rejected: Container Apps simpler for this scope

3. **Pulumi**: Alternative to Terraform
   - Rejected: Terraform more widely adopted

## References

- [Microsoft .NET Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [React Documentation](https://react.dev/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
