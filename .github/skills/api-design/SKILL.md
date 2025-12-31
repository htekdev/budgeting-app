---
name: api-design
description: REST API design patterns and best practices for BudgetBuddy
---

# API Design Skill

## Overview

This skill provides guidance on designing RESTful APIs following best practices, with specific examples from the BudgetBuddy application.

## Core Principles

1. **Resource-Oriented**: URLs represent resources, not actions
2. **HTTP Methods**: Use appropriate verbs (GET, POST, PUT, PATCH, DELETE)
3. **Status Codes**: Return meaningful HTTP status codes
4. **Versioning**: Version your API (we use `/api/v1/`)
5. **Consistent Naming**: Use plural nouns for collections
6. **Error Handling**: Return structured error responses
7. **Documentation**: OpenAPI/Swagger for all endpoints

## URL Design

### Resource Naming

```
Good:
GET    /api/v1/accounts           # List accounts
POST   /api/v1/accounts           # Create account
GET    /api/v1/accounts/{id}      # Get specific account
PUT    /api/v1/accounts/{id}      # Update account
DELETE /api/v1/accounts/{id}      # Delete account

GET    /api/v1/accounts/{id}/transactions  # Get transactions for account

Bad:
GET    /api/v1/getAccounts        # Action in URL
POST   /api/v1/account/create     # Singular + action
GET    /api/v1/account            # Inconsistent (singular vs plural)
```

### Query Parameters

Use for filtering, sorting, pagination:

```
GET /api/v1/transactions?userId=1&from=2024-01-01&to=2024-12-31
GET /api/v1/accounts?type=Checking&isActive=true
GET /api/v1/transactions?page=2&pageSize=50&sortBy=date&sortOrder=desc
```

## HTTP Methods

| Method | Purpose | Request Body | Response Body | Idempotent |
|--------|---------|--------------|---------------|------------|
| GET | Retrieve resource(s) | No | Yes | Yes |
| POST | Create new resource | Yes | Created resource | No |
| PUT | Replace entire resource | Yes | Updated resource | Yes |
| PATCH | Partial update | Yes | Updated resource | No |
| DELETE | Remove resource | No | Optional | Yes |

### GET - Retrieve Resources

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts(
    [FromQuery] int userId = 1,
    [FromQuery] bool? isActive = null)
{
    var query = _context.Accounts
        .Where(a => a.UserId == userId);

    if (isActive.HasValue)
    {
        query = query.Where(a => a.IsActive == isActive.Value);
    }

    var accounts = await query
        .Select(a => new AccountDto
        {
            AccountId = a.AccountId,
            AccountName = a.AccountName,
            AccountType = a.AccountType,
            CurrentBalance = a.CurrentBalance,
            Currency = a.Currency,
            IsActive = a.IsActive
        })
        .ToListAsync();

    return Ok(accounts);
}

[HttpGet("{id}")]
public async Task<ActionResult<AccountDto>> GetAccount(int id)
{
    var account = await _context.Accounts
        .Where(a => a.AccountId == id)
        .Select(a => new AccountDto { /* ... */ })
        .FirstOrDefaultAsync();

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

### POST - Create Resources

```csharp
[HttpPost]
public async Task<ActionResult<AccountDto>> CreateAccount(
    [FromBody] CreateAccountRequest request)
{
    // Validation (can use FluentValidation)
    if (string.IsNullOrWhiteSpace(request.AccountName))
    {
        return BadRequest(new ValidationProblemDetails
        {
            Title = "Validation failed",
            Detail = "AccountName is required",
            Status = StatusCodes.Status400BadRequest,
            Errors = new Dictionary<string, string[]>
            {
                ["AccountName"] = new[] { "Account name is required" }
            }
        });
    }

    var account = new Account
    {
        UserId = request.UserId,
        AccountName = request.AccountName,
        AccountType = request.AccountType,
        CurrentBalance = request.InitialBalance,
        Currency = request.Currency,
        IsActive = true
    };

    _context.Accounts.Add(account);
    await _context.SaveChangesAsync();

    var accountDto = new AccountDto
    {
        AccountId = account.AccountId,
        AccountName = account.AccountName,
        AccountType = account.AccountType,
        CurrentBalance = account.CurrentBalance,
        Currency = account.Currency,
        IsActive = account.IsActive
    };

    return CreatedAtAction(
        nameof(GetAccount),
        new { id = account.AccountId },
        accountDto
    );
}
```

### PUT - Update Resources

```csharp
[HttpPut("{id}")]
public async Task<ActionResult<AccountDto>> UpdateAccount(
    int id,
    [FromBody] UpdateAccountRequest request)
{
    var account = await _context.Accounts.FindAsync(id);

    if (account == null)
    {
        return NotFound();
    }

    // Update fields
    account.AccountName = request.AccountName;
    account.IsActive = request.IsActive;
    account.UpdatedAt = DateTime.UtcNow;

    await _context.SaveChangesAsync();

    var accountDto = new AccountDto { /* ... */ };

    return Ok(accountDto);
}
```

### DELETE - Remove Resources

```csharp
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteAccount(int id)
{
    var account = await _context.Accounts.FindAsync(id);

    if (account == null)
    {
        return NotFound();
    }

    // Soft delete (preferred)
    account.IsActive = false;
    account.UpdatedAt = DateTime.UtcNow;

    // OR Hard delete
    // _context.Accounts.Remove(account);

    await _context.SaveChangesAsync();

    return NoContent();
}
```

## HTTP Status Codes

Use appropriate status codes:

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 OK | Success | GET, PUT, PATCH with response body |
| 201 Created | Resource created | POST success |
| 204 No Content | Success, no response body | DELETE success, PUT/PATCH without body |
| 400 Bad Request | Invalid input | Validation errors |
| 401 Unauthorized | Authentication required | Missing/invalid auth token |
| 403 Forbidden | Authenticated but not authorized | User can't access resource |
| 404 Not Found | Resource doesn't exist | GET/PUT/DELETE non-existent resource |
| 409 Conflict | Resource conflict | Duplicate, concurrent modification |
| 500 Internal Server Error | Server error | Unexpected exceptions |

## Error Responses

Use ProblemDetails (RFC 7807):

```csharp
// 404 Not Found
return NotFound(new ProblemDetails
{
    Title = "Account not found",
    Detail = $"Account with ID {id} does not exist",
    Status = StatusCodes.Status404NotFound,
    Instance = $"/api/v1/accounts/{id}"
});

// 400 Bad Request with validation errors
return BadRequest(new ValidationProblemDetails
{
    Title = "Validation failed",
    Detail = "One or more validation errors occurred",
    Status = StatusCodes.Status400BadRequest,
    Errors = new Dictionary<string, string[]>
    {
        ["AccountName"] = new[] { "Account name is required", "Account name must be less than 200 characters" },
        ["Amount"] = new[] { "Amount must be positive" }
    }
});

// 500 Internal Server Error
return StatusCode(500, new ProblemDetails
{
    Title = "An error occurred",
    Detail = "An unexpected error occurred while processing your request",
    Status = StatusCodes.Status500InternalServerError
});
```

## Request/Response DTOs

Always use DTOs for API contracts:

```csharp
// Request DTOs
public record CreateAccountRequest
{
    public int UserId { get; init; }
    public string AccountName { get; init; } = string.Empty;
    public string AccountType { get; init; } = string.Empty;
    public decimal InitialBalance { get; init; }
    public string Currency { get; init; } = "USD";
}

// Response DTOs
public record AccountDto
{
    public int AccountId { get; init; }
    public string AccountName { get; init; } = string.Empty;
    public string AccountType { get; init; } = string.Empty;
    public decimal CurrentBalance { get; init; }
    public string Currency { get; init; } = "USD";
    public bool IsActive { get; init; }
}

// Never expose domain entities directly in API
// Bad:
[HttpGet]
public async Task<Account> GetAccount(int id) // Exposes internal model
```

## Pagination

For list endpoints that could return many results:

```csharp
public record PagedResult<T>
{
    public List<T> Items { get; init; } = new();
    public int Page { get; init; }
    public int PageSize { get; init; }
    public int TotalCount { get; init; }
    public int TotalPages { get; init; }
}

[HttpGet]
public async Task<ActionResult<PagedResult<TransactionDto>>> GetTransactions(
    [FromQuery] int userId = 1,
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 50)
{
    if (pageSize > 100) pageSize = 100; // Max limit

    var query = _context.Transactions
        .Where(t => t.UserId == userId);

    var totalCount = await query.CountAsync();
    var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

    var items = await query
        .OrderByDescending(t => t.TransactionDate)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .Select(t => new TransactionDto { /* ... */ })
        .ToListAsync();

    return Ok(new PagedResult<TransactionDto>
    {
        Items = items,
        Page = page,
        PageSize = pageSize,
        TotalCount = totalCount,
        TotalPages = totalPages
    });
}
```

## Filtering and Searching

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactions(
    [FromQuery] int userId = 1,
    [FromQuery] DateTime? from = null,
    [FromQuery] DateTime? to = null,
    [FromQuery] int? accountId = null,
    [FromQuery] int? categoryId = null,
    [FromQuery] string? transactionType = null,
    [FromQuery] string? search = null)
{
    var query = _context.Transactions
        .Where(t => t.UserId == userId)
        .AsQueryable();

    if (from.HasValue)
        query = query.Where(t => t.TransactionDate >= from.Value);

    if (to.HasValue)
        query = query.Where(t => t.TransactionDate <= to.Value);

    if (accountId.HasValue)
        query = query.Where(t => t.AccountId == accountId.Value);

    if (categoryId.HasValue)
        query = query.Where(t => t.CategoryId == categoryId.Value);

    if (!string.IsNullOrWhiteSpace(transactionType))
        query = query.Where(t => t.TransactionType == transactionType);

    if (!string.IsNullOrWhiteSpace(search))
        query = query.Where(t => t.Description.Contains(search));

    var transactions = await query
        .OrderByDescending(t => t.TransactionDate)
        .Select(t => new TransactionDto { /* ... */ })
        .ToListAsync();

    return Ok(transactions);
}
```

## API Documentation (Swagger)

Document all endpoints:

```csharp
/// <summary>
/// Gets all accounts for a user
/// </summary>
/// <param name="userId">User ID</param>
/// <param name="isActive">Filter by active status</param>
/// <returns>List of accounts</returns>
/// <response code="200">Returns the list of accounts</response>
/// <response code="401">If the user is not authenticated</response>
[HttpGet]
[ProducesResponseType(typeof(IEnumerable<AccountDto>), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts(
    [FromQuery] int userId = 1,
    [FromQuery] bool? isActive = null)
{
    // Implementation
}
```

## Best Practices Checklist

- [ ] Use resource-oriented URLs
- [ ] Use appropriate HTTP methods
- [ ] Return proper status codes
- [ ] Use DTOs for requests and responses
- [ ] Validate all inputs
- [ ] Return structured errors (ProblemDetails)
- [ ] Document with Swagger/OpenAPI
- [ ] Version your API
- [ ] Implement pagination for lists
- [ ] Support filtering and searching
- [ ] Use async/await for database operations
- [ ] Log important operations
- [ ] Handle exceptions gracefully
- [ ] Include health check endpoint
- [ ] Enable CORS for frontend
