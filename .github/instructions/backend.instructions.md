---
applyTo:
  - '**/*.cs'
---

# C# Backend Instructions

## Coding Standards
- Use C# 13 language features
- Enable nullable reference types
- Use file-scoped namespaces
- Use record types for immutable data (DTOs, value objects)
- Prefer expression-bodied members for simple methods
- Use pattern matching where appropriate

## Entity Framework Core
- Always use async methods (ToListAsync, FirstOrDefaultAsync, etc.)
- Use proper tracking vs. no-tracking queries
- Include related entities explicitly when needed
- Use migrations for all schema changes
- Add meaningful migration names

## API Controllers
- Inherit from ControllerBase
- Use [ApiController] attribute
- Use proper route templates ([Route("api/[controller]")])
- Return ActionResult<T> from controller actions
- Use ProducesResponseType attributes for OpenAPI documentation
- Validate input using Data Annotations or FluentValidation
- Log all important operations

## Dependency Injection
- Register services in Program.cs
- Use constructor injection
- Prefer interface-based dependencies
- Use appropriate service lifetimes (Singleton, Scoped, Transient)

## Error Handling
- Use try-catch blocks for expected exceptions
- Return appropriate HTTP status codes
- Include meaningful error messages
- Log exceptions with context

## Example Controller Pattern
```csharp
[ApiController]
[Route("api/[controller]")]
public class ExampleController : ControllerBase
{
    private readonly IExampleService _service;
    private readonly ILogger<ExampleController> _logger;

    public ExampleController(IExampleService service, ILogger<ExampleController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<ExampleDto>>> GetAll()
    {
        _logger.LogInformation("Fetching all items");
        var items = await _service.GetAllAsync();
        return Ok(items);
    }
}
```
