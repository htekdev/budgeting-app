---
applyTo:
  - "backend/**/*.cs"
  - "backend/**/*.csproj"
---

# Backend-Specific Instructions

## .NET 10 API Development

### Project Structure
- Controllers in Controllers/ directory
- Models in Models/ directory
- Services in Services/ directory
- Data access in Data/ directory

### Controller Guidelines
- Inherit from ControllerBase for APIs
- Use [ApiController] attribute
- Use [Route("api/[controller]")] or explicit routes
- Return ActionResult<T> or IActionResult
- Use async Task<IActionResult> for all actions

### Entity Framework Core
- DbContext in Data/ directory
- Use Code First with migrations
- Always include navigation properties
- Use fluent API for complex configurations
- Implement IEntityTypeConfiguration<T> for entity configs

### Dependency Injection
- Register services in Program.cs
- Use interface-based DI
- Prefer scoped lifetime for services with DbContext
- Use transient for stateless services
- Use singleton carefully (stateless only)

### Validation
- Use Data Annotations on models
- Implement FluentValidation for complex validation
- Always validate inputs in controllers
- Return 400 Bad Request for validation errors

### Error Responses
- Use ProblemDetails for error responses
- Include error codes and messages
- Never expose stack traces in production
- Log all errors with correlation IDs

### Security
- Use [Authorize] attribute for protected endpoints
- Implement JWT authentication
- Use [AllowAnonymous] explicitly when needed
- Validate JWT tokens properly
- Implement rate limiting

### Testing
- Use xUnit for testing
- Mock DbContext with InMemory provider or Moq
- Test controllers separately from business logic
- Use WebApplicationFactory for integration tests
