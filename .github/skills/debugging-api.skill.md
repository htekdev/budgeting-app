# Debugging API Issues Skill

Systematic approach to debugging API problems.

## Symptoms & Solutions

### 1. API Returns 500 Internal Server Error
**Check:**
- Application logs in the console
- Exception details in Application Insights
- Database connection string
- Missing required configuration

**Debug:**
```bash
# Enable detailed errors
export ASPNETCORE_ENVIRONMENT=Development
dotnet run

# Check database connectivity
dotnet ef database update
```

### 2. API Returns 404 Not Found
**Check:**
- Route configuration in controller
- Request URL matches route template
- Controller is registered in dependency injection
- Middleware order in Program.cs

### 3. API Returns 401 Unauthorized
**Check:**
- Authentication middleware is configured
- JWT token is valid and not expired
- Token is included in Authorization header
- Claims are properly configured

### 4. CORS Errors in Frontend
**Check:**
- CORS policy is configured in backend
- Frontend origin is in allowed origins list
- CORS middleware is before routing middleware
- Credentials are properly configured

**Fix:**
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

app.UseCors("AllowFrontend");
```

### 5. Slow API Response
**Investigate:**
- Database query performance (check with SQL Profiler)
- N+1 query problems
- Missing database indexes
- Large payload sizes

**Optimize:**
```csharp
// Use AsNoTracking for read-only queries
var budgets = await _context.Budgets
    .AsNoTracking()
    .ToListAsync();

// Include related entities efficiently
var budget = await _context.Budgets
    .Include(b => b.Categories)
    .FirstOrDefaultAsync(b => b.Id == id);
```

### 6. Database Connection Errors
**Check:**
- Connection string format
- SQL Server is running
- Firewall rules allow connection
- Database exists
- Credentials are correct

### 7. Serialization Errors
**Check:**
- Circular references in entities
- Navigation properties causing loops
- DTOs are properly mapped

**Fix:**
```csharp
// Use DTOs to avoid circular references
var budgetDto = new BudgetDto(
    budget.Id,
    budget.Name,
    budget.TotalAmount
);
```

## General Debugging Tools
- `dotnet watch run` for hot reload
- Swagger UI at `/swagger`
- Health check endpoint at `/health`
- SQL Server Management Studio or Azure Data Studio
- Browser DevTools Network tab
- Postman or curl for API testing

## Logging
Add detailed logging to troubleshoot:
```csharp
_logger.LogInformation("Fetching budget with ID: {BudgetId}", id);
_logger.LogWarning("Budget {BudgetId} not found", id);
_logger.LogError(ex, "Error creating budget: {BudgetName}", dto.Name);
```
