---
name: API Design
description: RESTful API design patterns and best practices for BudgetBuddy
---

# API Design Skill

## Overview

This skill provides guidance on designing RESTful APIs that are consistent, maintainable, and follow industry best practices.

## RESTful Principles

### Resource Naming

**DO**:
- Use plural nouns for collections: `/api/v1/accounts`, `/api/v1/transactions`
- Use kebab-case for multi-word resources: `/recurring-transactions`
- Use nested routes for relationships: `/api/v1/accounts/{id}/transactions`

**DON'T**:
- Use verbs in URLs: `/api/v1/getAccounts` ❌
- Mix singular and plural: `/api/v1/account` and `/api/v1/transactions` ❌

### HTTP Methods

- **GET**: Retrieve resource(s), idempotent, safe
- **POST**: Create new resource
- **PUT**: Update entire resource (replace)
- **PATCH**: Partial update
- **DELETE**: Remove resource

### Status Codes

- `200 OK`: Successful GET, PUT, PATCH
- `201 Created`: Successful POST, include Location header
- `204 No Content`: Successful DELETE or update with no response body
- `400 Bad Request`: Invalid input, validation errors
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Authenticated but not authorized
- `404 Not Found`: Resource doesn't exist
- `409 Conflict`: Resource conflict (e.g., duplicate)
- `500 Internal Server Error`: Server error

## Endpoint Patterns

### Collection Operations

```
GET    /api/v1/accounts              - List all accounts
POST   /api/v1/accounts              - Create new account
GET    /api/v1/accounts/{id}         - Get specific account
PUT    /api/v1/accounts/{id}         - Update account (full)
PATCH  /api/v1/accounts/{id}         - Update account (partial)
DELETE /api/v1/accounts/{id}         - Delete account
```

### Query Parameters

**Filtering**:
```
GET /api/v1/transactions?accountId=1&categoryId=5
GET /api/v1/transactions?from=2025-01-01&to=2025-01-31
```

**Pagination**:
```
GET /api/v1/transactions?page=1&pageSize=50
```

**Sorting**:
```
GET /api/v1/transactions?sortBy=date&sortOrder=desc
```

**Field Selection**:
```
GET /api/v1/accounts?fields=id,name,balance
```

### Sub-resources

```
GET /api/v1/accounts/{id}/transactions
GET /api/v1/budgets/{id}/actuals
POST /api/v1/goals/{id}/contributions
```

### Actions (Non-CRUD)

For operations that don't fit CRUD:
```
POST /api/v1/transactions/import            - Import transactions
POST /api/v1/recurring/{id}/generate         - Generate instances
POST /api/v1/budgets/summary                 - Get budget summary
```

## Request/Response Format

### Request Body (POST/PUT)

```json
{
  "name": "Checking Account",
  "type": "Checking",
  "balance": 5000.00,
  "currency": "USD"
}
```

### Successful Response

```json
{
  "id": 1,
  "name": "Checking Account",
  "type": "Checking",
  "balance": 5000.00,
  "currency": "USD",
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z"
}
```

### Error Response (ProblemDetails)

```json
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Name": ["The Name field is required."],
    "Balance": ["Balance must be a valid number."]
  }
}
```

### Collection Response

```json
{
  "data": [
    { "id": 1, "name": "Account 1" },
    { "id": 2, "name": "Account 2" }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 42,
    "totalPages": 3
  }
}
```

## Versioning

Use URL versioning for major breaking changes:
```
/api/v1/accounts
/api/v2/accounts
```

## API Documentation

### Swagger/OpenAPI

Add XML comments to controllers:

```csharp
/// <summary>
/// Gets all accounts for the specified user
/// </summary>
/// <param name="userId">The user ID</param>
/// <returns>List of accounts</returns>
/// <response code="200">Returns the list of accounts</response>
/// <response code="401">If the user is not authenticated</response>
[HttpGet]
[ProducesResponseType(StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts([FromQuery] int userId)
```

## Security Considerations

- **Authentication**: Use JWT tokens or similar
- **Authorization**: Check user permissions for resources
- **Input Validation**: Validate all inputs
- **Rate Limiting**: Implement rate limiting for public APIs
- **HTTPS**: Always use HTTPS in production
- **CORS**: Configure CORS appropriately

## Common Pitfalls

### ❌ Returning Domain Entities

```csharp
// DON'T
[HttpGet]
public async Task<IEnumerable<Account>> GetAccounts()
{
    return await _context.Accounts.ToListAsync();
}
```

### ✅ Use DTOs

```csharp
// DO
[HttpGet]
public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts()
{
    var accounts = await _service.GetAllAccountsAsync();
    return Ok(accounts);
}
```

### ❌ Exposing Implementation Details

```csharp
// DON'T
GET /api/v1/GetAccountsByUserId?id=1
```

### ✅ Resource-Oriented

```csharp
// DO
GET /api/v1/accounts?userId=1
```

## Testing APIs

### Unit Tests

Test service logic in isolation:

```csharp
[Fact]
public async Task GetAccountAsync_ReturnsAccount_WhenExists()
{
    // Arrange
    var accountId = 1;
    var expectedAccount = new AccountDto { Id = accountId, Name = "Test" };
    _mockService.Setup(s => s.GetAccountAsync(accountId))
        .ReturnsAsync(expectedAccount);
    
    // Act
    var result = await _controller.GetAccount(accountId);
    
    // Assert
    var okResult = Assert.IsType<OkObjectResult>(result.Result);
    var account = Assert.IsType<AccountDto>(okResult.Value);
    Assert.Equal(accountId, account.Id);
}
```

### Integration Tests

Test full HTTP pipeline:

```csharp
[Fact]
public async Task GetAccounts_ReturnsOkStatus()
{
    // Arrange
    var client = _factory.CreateClient();
    
    // Act
    var response = await client.GetAsync("/api/v1/accounts?userId=1");
    
    // Assert
    response.EnsureSuccessStatusCode();
    var accounts = await response.Content.ReadFromJsonAsync<List<AccountDto>>();
    Assert.NotNull(accounts);
}
```

## Performance Considerations

- Use pagination for large collections
- Implement caching where appropriate
- Use async/await for I/O operations
- Avoid N+1 queries (use Include/ThenInclude in EF)
- Consider GraphQL for complex queries

## Example: Complete Endpoint

```csharp
[ApiController]
[Route("api/v1/[controller]")]
public class AccountsController : ControllerBase
{
    private readonly IAccountService _service;
    private readonly ILogger<AccountsController> _logger;

    public AccountsController(IAccountService service, ILogger<AccountsController> logger)
    {
        _service = service;
        _logger = logger;
    }

    /// <summary>
    /// Gets all accounts for a user
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts([FromQuery] int userId)
    {
        try
        {
            var accounts = await _service.GetAllAccountsAsync(userId);
            return Ok(accounts);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving accounts for user {UserId}", userId);
            return StatusCode(500, new { error = "An error occurred while retrieving accounts" });
        }
    }

    /// <summary>
    /// Creates a new account
    /// </summary>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<AccountDto>> CreateAccount([FromBody] CreateAccountDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var account = await _service.CreateAccountAsync(dto);
            return CreatedAtAction(nameof(GetAccount), new { id = account.Id }, account);
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning(ex, "Validation error creating account");
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating account");
            return StatusCode(500, new { error = "An error occurred while creating the account" });
        }
    }
}
```

## References

- [REST API Tutorial](https://restfulapi.net/)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [RFC 9110 (HTTP Semantics)](https://tools.ietf.org/html/rfc9110)
- [Problem Details RFC 7807](https://tools.ietf.org/html/rfc7807)
