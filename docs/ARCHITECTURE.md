# BudgetBuddy Architecture

## Overview

BudgetBuddy is built using a modern, cloud-native architecture with clear separation of concerns across frontend, backend, and data layers.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
├─────────────────────────────────────────────────────────────────┤
│  Browser/Mobile                                                  │
│  ┌──────────────────────────────────────────────────────┐       │
│  │  React Application (TypeScript)                       │       │
│  │  - Component-based UI                                 │       │
│  │  - Custom Hooks for state management                 │       │
│  │  - API Service Integration                            │       │
│  └──────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / REST API
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                           │
├─────────────────────────────────────────────────────────────────┤
│  ASP.NET Core Web API                                           │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  Controllers                                          │      │
│  │  ├─ BudgetsController                                 │      │
│  │  ├─ TransactionsController                            │      │
│  │  └─ CategoriesController (future)                     │      │
│  └──────────────────────────────────────────────────────┘      │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  DTOs (Data Transfer Objects)                         │      │
│  │  - Request/Response Models                            │      │
│  │  - Validation Attributes                              │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Entity Framework Core
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐      │
│  │  DbContext                                            │      │
│  │  - Entity Configuration                               │      │
│  │  - Migrations                                         │      │
│  │  - Seed Data                                          │      │
│  └──────────────────────────────────────────────────────┘      │
│                              │                                   │
│                              ▼                                   │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  Domain Models                                        │      │
│  │  ├─ Budget                                            │      │
│  │  ├─ Transaction                                       │      │
│  │  └─ Category                                          │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ ADO.NET / TDS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Database Layer                               │
├─────────────────────────────────────────────────────────────────┤
│  SQL Server 2022                                                │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  Tables                                               │      │
│  │  ├─ Budgets                                           │      │
│  │  ├─ Transactions                                      │      │
│  │  └─ Categories                                        │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### Frontend (React + TypeScript)

**Technology Stack:**
- React 19 with functional components and hooks
- TypeScript for type safety
- Vite for fast development and optimized builds
- Custom hooks for data fetching and state management

**Key Components:**
- `BudgetCard`: Displays budget summary
- `TransactionList`: Shows transaction history with filtering
- `AddTransactionForm`: Form for creating new transactions

**State Management:**
- Local component state with `useState`
- Custom hooks (`useBudgets`, `useTransactions`) for API data
- No global state library (future: consider React Context or Zustand)

**API Integration:**
- Service layer pattern (`services/api.ts`)
- Fetch API for HTTP requests
- Environment variables for API URL configuration

### Backend (ASP.NET Core)

**Technology Stack:**
- ASP.NET Core 10 Web API
- Entity Framework Core 10
- C# 13 with modern language features
- Dependency Injection for loose coupling

**Architecture Pattern:**
- **Controllers**: Handle HTTP requests/responses
- **DTOs**: Data transfer between API and clients
- **Models**: Domain entities representing business concepts
- **DbContext**: Database access and configuration

**Key Features:**
- RESTful API design
- Swagger/OpenAPI documentation
- Structured logging with ILogger
- Health checks for monitoring
- CORS configuration for frontend

**Design Patterns:**
- Repository pattern (via EF Core DbContext)
- Dependency Injection
- DTO pattern for API contracts
- Factory pattern (via DI container)

### Database (SQL Server)

**Schema Design:**

```sql
Budgets
├── Id (PK)
├── Name
├── TotalAmount
├── StartDate
├── EndDate
├── UserId
├── CreatedAt
└── UpdatedAt

Categories
├── Id (PK)
├── Name
├── AllocatedAmount
├── Color
└── BudgetId (FK -> Budgets.Id)

Transactions
├── Id (PK)
├── Description
├── Amount
├── Date
├── Type (Income/Expense)
├── BudgetId (FK -> Budgets.Id)
├── CategoryId (FK -> Categories.Id, nullable)
└── CreatedAt
```

**Relationships:**
- Budget → Categories (One-to-Many, Cascade Delete)
- Budget → Transactions (One-to-Many, Cascade Delete)
- Category → Transactions (One-to-Many, Set Null on Delete)

## Deployment Architecture

### Local Development

```
Docker Compose
├── SQL Server Container (Port 1433)
├── Backend Container (Port 5000)
└── Frontend Container (Port 3000)
```

### Azure Production

```
Azure Resource Group
├── App Service Plan (Linux, B1)
├── Backend App Service
│   ├── ASP.NET Core 10 Runtime
│   ├── System-Assigned Managed Identity
│   └── Connection to SQL Database
├── Frontend App Service
│   ├── Node.js 20 Runtime
│   └── Static File Serving
├── Azure SQL Server
│   ├── SQL Database
│   ├── Firewall Rules
│   └── Azure AD Authentication
└── Application Insights
    ├── Performance Monitoring
    ├── Error Tracking
    └── Usage Analytics
```

## Data Flow

### Creating a Budget

```
1. User fills form in React component
   ↓
2. Frontend validates input
   ↓
3. POST request to /api/budgets
   ↓
4. Backend validates DTO
   ↓
5. Controller creates Budget entity
   ↓
6. EF Core saves to database
   ↓
7. Database returns generated ID
   ↓
8. Backend returns BudgetDto (201 Created)
   ↓
9. Frontend updates UI with new budget
```

### Adding a Transaction

```
1. User submits transaction form
   ↓
2. Frontend validates input
   ↓
3. POST request to /api/transactions
   ↓
4. Backend validates DTO and budget existence
   ↓
5. Controller creates Transaction entity
   ↓
6. EF Core saves to database
   ↓
7. Database enforces foreign key constraints
   ↓
8. Backend returns TransactionDto (201 Created)
   ↓
9. Frontend refreshes transaction list
```

## Security Architecture

### Current Implementation

- **Input Validation**: Both client and server-side
- **SQL Injection Prevention**: EF Core parameterized queries
- **XSS Prevention**: React automatic escaping
- **CORS**: Configured with specific origins
- **HTTPS**: Enforced in production
- **Secrets Management**: Environment variables

### Future Enhancements

- JWT-based authentication
- Azure AD B2C integration
- Role-based authorization
- API rate limiting
- Request/response encryption
- Audit logging

## Scalability Considerations

### Current Design

- **Stateless API**: Horizontal scaling ready
- **Database Pooling**: EF Core connection pooling
- **Async/Await**: Non-blocking I/O operations
- **Health Checks**: For load balancer integration

### Future Optimizations

- Redis caching layer
- CDN for frontend assets
- Database read replicas
- Azure Front Door for global distribution
- Queue-based processing for long operations
- API pagination for large datasets

## Monitoring & Observability

### Logging

- Structured logging with ILogger
- Log levels: Information, Warning, Error
- Context-aware logging (request ID, user ID)

### Metrics

- Application Insights integration
- Performance counters
- Custom metrics (budgets created, transactions added)
- Error tracking and alerting

### Health Checks

- Database connectivity
- External service dependencies
- Resource utilization

## Development Workflow

```
Developer Workstation
      ↓
Git Commit & Push
      ↓
GitHub Actions CI/CD
├── Build Backend
├── Build Frontend
├── Run Tests
├── Security Scanning (CodeQL)
├── Dependency Review
└── Deploy (optional)
      ↓
Azure Resources
├── Backend App Service
├── Frontend App Service
└── SQL Database
```

## Technology Decisions

### Why React?

- Component-based architecture
- Strong ecosystem
- TypeScript support
- Hooks for clean state management
- Wide adoption and community

### Why ASP.NET Core?

- High performance
- Cross-platform
- Built-in DI and middleware
- Strong typing with C#
- Excellent Azure integration

### Why SQL Server?

- ACID compliance
- Strong relational model
- Entity Framework Core support
- Azure SQL Database integration
- Proven scalability

### Why Terraform?

- Infrastructure as Code
- Version control for infrastructure
- Multi-cloud support
- Strong Azure provider
- Declarative syntax

## Future Architecture Evolution

### Phase 2: Authentication

- Add Azure AD B2C
- JWT token-based auth
- User management

### Phase 3: Advanced Features

- Real-time updates (SignalR)
- Background jobs (Hangfire)
- File uploads (Azure Blob Storage)
- Notifications (Azure Service Bus)

### Phase 4: Microservices (If Needed)

- Split into separate services
- API Gateway pattern
- Event-driven architecture
- Service mesh

## References

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Microsoft Architecture Guides](https://docs.microsoft.com/en-us/dotnet/architecture/)
- [React Best Practices](https://react.dev/learn)
- [Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)
