---
description: "Backend C# code style and patterns for BudgetBuddy API"
applyTo: "src/backend/**/*.cs"
---

# Backend C# Instructions

## Code Style
- Use C# 12+ features (file-scoped namespaces, required properties, init accessors)
- Prefer Minimal APIs over Controllers
- Use async/await for all I/O operations
- Follow Clean Architecture layers: Domain → Infrastructure → API

## Naming Conventions
- Classes: PascalCase
- Methods: PascalCase
- Parameters/variables: camelCase
- Private fields: _camelCase with underscore prefix
- Constants: PascalCase

## Domain Layer (BudgetBuddy.Domain)
- Pure domain models with no dependencies on other layers
- Use required properties for mandatory fields
- Inherit from BaseEntity for common properties (Id, CreatedAt, UpdatedAt)
- Keep domain logic in entity methods when appropriate
- Use value objects for complex types

## Infrastructure Layer (BudgetBuddy.Infrastructure)
- Repository pattern for data access
- DbContext configuration using Fluent API
- Migrations for schema changes
- Seed data in DbInitializer
- Configure relationships explicitly

## API Layer (BudgetBuddy.API)
- Group endpoints by resource (Budgets, Transactions, Categories, Users)
- Use .WithName() and .WithTags() for all endpoints
- Implement pagination: `async (int page = 1, int pageSize = 10)`
- Return proper HTTP status codes (Ok, Created, NotFound, NoContent)
- Use Results class for responses
- Add health checks for dependencies

## Error Handling
- Use Results.NotFound() for missing entities
- Use Results.BadRequest() for validation errors
- Use Results.Problem() for unexpected errors
- Log errors with context using Serilog

## Testing
- Use xUnit for unit tests
- Use WebApplicationFactory for integration tests
- Mock DbContext with InMemory provider for unit tests
- Test both success and error scenarios

## Examples

### Creating Entity
```csharp
public class Budget : BaseEntity
{
    public required string Name { get; set; }
    public decimal TotalAmount { get; set; }
    public required Guid UserId { get; set; }
    public User User { get; set; } = null!;
}
```

### API Endpoint with Pagination
```csharp
app.MapGet("/api/budgets", async (BudgetBuddyDbContext db, int page = 1, int pageSize = 10) =>
{
    var budgets = await db.Budgets
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
    
    return Results.Ok(budgets);
})
.WithName("GetBudgets")
.WithTags("Budgets");
```

### DbContext Configuration
```csharp
modelBuilder.Entity<Budget>(entity =>
{
    entity.HasKey(e => e.Id);
    entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
    entity.Property(e => e.TotalAmount).HasPrecision(18, 2);
    entity.HasOne(e => e.User)
          .WithMany(u => u.Budgets)
          .HasForeignKey(e => e.UserId)
          .OnDelete(DeleteBehavior.Cascade);
});
```
