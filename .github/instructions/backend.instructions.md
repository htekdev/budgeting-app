---
applyTo:
  - "**/*.cs"
  - "**/*.csproj"
  - "src/backend/**"
---

# Backend Instructions (C#)

## Project Structure

Follow Clean Architecture layering:

- **Domain**: Entities, value objects (no dependencies)
- **Application**: DTOs, commands, queries, interfaces
- **Infrastructure**: EF Core, repositories, external services
- **API**: Controllers, middleware

Dependencies flow inward: API → Infrastructure → Application → Domain

## C# Conventions

```csharp
// Good
public class AccountsController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<AccountsController> _logger;

    public AccountsController(
        BudgetBuddyDbContext context,
        ILogger<AccountsController> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts(
        [FromQuery] int userId,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching accounts for user {UserId}", userId);
        
        var accounts = await _context.Accounts
            .Where(a => a.UserId == userId && a.IsActive)
            .ToListAsync(cancellationToken);
            
        return Ok(accounts);
    }
}
```

## Async/Await

- Always use async for I/O operations
- Include CancellationToken parameter
- Don't use `.Result` or `.Wait()` (causes deadlocks)

```csharp
// Good
public async Task<Account> GetAccountAsync(int id, CancellationToken cancellationToken)
{
    return await _context.Accounts
        .FirstOrDefaultAsync(a => a.AccountId == id, cancellationToken);
}

// Bad
public Account GetAccount(int id)
{
    return _context.Accounts
        .FirstOrDefault(a => a.AccountId == id);
}
```

## Logging

Use structured logging with ILogger:

```csharp
_logger.LogInformation(
    "Creating account {AccountName} for user {UserId}", 
    accountName, 
    userId
);

_logger.LogWarning(
    "Account {AccountId} not found for user {UserId}", 
    accountId, 
    userId
);

_logger.LogError(
    exception,
    "Failed to create account for user {UserId}", 
    userId
);
```

## Error Handling

Return ProblemDetails for API errors:

```csharp
[HttpGet("{id}")]
public async Task<ActionResult<AccountDto>> GetAccount(int id)
{
    var account = await _context.Accounts.FindAsync(id);
    
    if (account == null)
    {
        return NotFound(new ProblemDetails
        {
            Title = "Account not found",
            Detail = $"Account with ID {id} does not exist",
            Status = StatusCodes.Status404NotFound
        });
    }
    
    return Ok(account);
}
```

## Validation

Use FluentValidation for complex validation:

```csharp
public class CreateAccountRequestValidator : AbstractValidator<CreateAccountRequest>
{
    public CreateAccountRequestValidator()
    {
        RuleFor(x => x.AccountName)
            .NotEmpty()
            .MaximumLength(200);
            
        RuleFor(x => x.AccountType)
            .NotEmpty()
            .Must(BeValidAccountType)
            .WithMessage("Account type must be Checking, Savings, Credit, or Investment");
            
        RuleFor(x => x.InitialBalance)
            .GreaterThanOrEqualTo(0)
            .When(x => x.AccountType != "Credit");
    }
    
    private bool BeValidAccountType(string accountType)
    {
        return new[] { "Checking", "Savings", "Credit", "Investment" }
            .Contains(accountType);
    }
}
```

## Dependency Injection

Use constructor injection:

```csharp
public class AccountsService
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<AccountsService> _logger;

    public AccountsService(
        BudgetBuddyDbContext context,
        ILogger<AccountsService> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }
}

// Register in Program.cs
builder.Services.AddScoped<AccountsService>();
```

## Entity Framework Core

- Use async methods
- Include related entities explicitly
- Use projections for read-only queries
- Avoid N+1 queries

```csharp
// Good - projection
var transactions = await _context.Transactions
    .Where(t => t.UserId == userId)
    .Select(t => new TransactionDto
    {
        TransactionId = t.TransactionId,
        AccountName = t.Account.AccountName,
        CategoryName = t.Category.CategoryName,
        Amount = t.Amount
    })
    .ToListAsync();

// Bad - N+1 queries
var transactions = await _context.Transactions
    .Where(t => t.UserId == userId)
    .ToListAsync();
// Accessing t.Account.AccountName causes additional query
```

## Testing

Write unit tests for business logic:

```csharp
public class BudgetServiceTests
{
    [Fact]
    public void CalculateVariance_WhenBudgetExceeded_ReturnsNegative()
    {
        // Arrange
        var budgetAmount = 100m;
        var actualAmount = 150m;
        
        // Act
        var variance = BudgetService.CalculateVariance(budgetAmount, actualAmount);
        
        // Assert
        Assert.Equal(-50m, variance);
    }
}
```

Write integration tests for APIs:

```csharp
public class AccountsControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    
    public AccountsControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task GetAccounts_ReturnsOk()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/accounts?userId=1");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var accounts = await response.Content.ReadFromJsonAsync<List<AccountDto>>();
        Assert.NotNull(accounts);
    }
}
```

## Nullable Reference Types

- Enabled in all projects
- Use `?` for nullable references
- Use `!` null-forgiving operator sparingly

```csharp
// Good
public class Account
{
    public int AccountId { get; set; }
    public string AccountName { get; set; } = string.Empty;
    public string? Notes { get; set; }  // Nullable
    public User User { get; set; } = null!;  // Set by EF Core
}
```

## Security

- Validate all inputs
- Use parameterized queries (EF Core does this)
- Don't expose sensitive data in logs
- Use authentication and authorization
- Rate limit APIs
