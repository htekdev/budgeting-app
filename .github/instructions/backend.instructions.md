---
applyTo:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/src/backend/**"
---

# Backend Development Instructions

## C# & ASP.NET Core Best Practices

### Clean Architecture Layers

**BudgetBuddy.Domain** (Core Business Logic)
- Pure business entities
- No external dependencies
- Domain models only

**BudgetBuddy.Application** (Use Cases)
- Business logic and orchestration
- Service interfaces and implementations
- DTOs for data transfer
- Can depend on Domain only

**BudgetBuddy.Infrastructure** (Data Access)
- EF Core DbContext
- Repository implementations
- External service integrations
- Depends on Domain and Application

**BudgetBuddy.Api** (Presentation)
- Controllers (thin, delegate to services)
- API models/DTOs
- Middleware configuration
- Depends on all layers

### Controller Guidelines

```csharp
// DO: Keep controllers thin
[ApiController]
[Route("api/v1/[controller]")]
public class AccountsController : ControllerBase
{
    private readonly IAccountService _service;
    
    public AccountsController(IAccountService service)
    {
        _service = service;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAll()
    {
        var accounts = await _service.GetAllAsync();
        return Ok(accounts);
    }
}

// DON'T: Put business logic in controllers
```

### Async/Await

- Use `async/await` for all I/O operations
- Suffix async methods with `Async`
- Never use `.Result` or `.Wait()` - use `await`
- Use `ConfigureAwait(false)` in library code (not needed in ASP.NET Core)

### Error Handling

- Use ProblemDetails for error responses
- Add global exception middleware
- Log exceptions with structured logging
- Return appropriate HTTP status codes

### Dependency Injection

- Register services in `Program.cs`
- Use constructor injection
- Prefer interfaces over concrete types
- Use appropriate service lifetimes:
  - Singleton: Stateless services
  - Scoped: Per-request services (DbContext)
  - Transient: Lightweight, stateless services

### Entity Framework Core

```csharp
// DO: Use async methods
var accounts = await _context.Accounts.ToListAsync();

// DO: Use explicit loading when needed
await _context.Entry(account).Collection(a => a.Transactions).LoadAsync();

// DON'T: Use lazy loading (it can cause N+1 problems)

// DO: Use transactions for multiple operations
using var transaction = await _context.Database.BeginTransactionAsync();
try
{
    // Multiple operations
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

### Testing

- Write unit tests for business logic
- Use xUnit as test framework
- Use FluentAssertions for readable assertions
- Mock dependencies with Moq
- Use Testcontainers for integration tests

## Validation Commands

```bash
cd src/backend

# Restore packages
dotnet restore

# Build
dotnet build

# Run tests
dotnet test

# Format code
dotnet format

# Run API
dotnet run --project BudgetBuddy.Api
```

## Code Review Checklist

- [ ] Follows Clean Architecture layer boundaries
- [ ] Async/await used for I/O operations
- [ ] Dependency injection used properly
- [ ] Error handling implemented
- [ ] Logging added for important operations
- [ ] Unit tests included
- [ ] XML documentation for public APIs
- [ ] No DbContext used directly in controllers
