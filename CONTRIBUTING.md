# Contributing to BudgetBuddy

Thank you for your interest in contributing to BudgetBuddy! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots** (if applicable)
- **Environment details** (OS, browser, .NET version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear use case**
- **Proposed solution**
- **Alternatives considered**
- **Additional context**

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch** from `main`
3. **Make your changes** following our coding standards
4. **Write or update tests**
5. **Update documentation** as needed
6. **Ensure all tests pass**
7. **Submit a pull request**

## Development Setup

See the [README.md](README.md) for detailed setup instructions.

## Coding Standards

### C# Backend

- Follow [Microsoft C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- Use async/await for I/O operations
- Add XML documentation for public APIs
- Write unit tests for all business logic
- Use dependency injection

### TypeScript Frontend

- Follow the [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Use functional components with hooks
- Add TypeScript types for all props and state
- Write tests for components and hooks
- Keep components small and focused

### General

- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Add comments for complex logic
- Update documentation for new features
- Ensure code is properly formatted

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(api): add budget sharing endpoint
fix(ui): resolve transaction list rendering issue
docs: update deployment guide with Azure steps
```

## Testing Guidelines

### Backend Tests

- Use xUnit for unit tests
- Mock external dependencies
- Test both success and error cases
- Aim for >80% code coverage

```csharp
[Fact]
public async Task CreateBudget_WithValidData_ReturnsBudget()
{
    // Arrange
    var dto = new CreateBudgetDto("Test", 1000m, DateTime.Now, DateTime.Now.AddDays(30), "user1");
    
    // Act
    var result = await _controller.CreateBudget(dto);
    
    // Assert
    var createdResult = Assert.IsType<CreatedAtActionResult>(result.Result);
    var budget = Assert.IsType<BudgetDto>(createdResult.Value);
    Assert.Equal("Test", budget.Name);
}
```

### Frontend Tests

- Use Vitest/Jest for unit tests
- Test user interactions
- Mock API calls
- Test error states

```typescript
describe('BudgetCard', () => {
  it('should display budget information', () => {
    const budget = { id: 1, name: 'Test Budget', totalAmount: 1000 };
    const { getByText } = render(<BudgetCard budget={budget} onSelect={vi.fn()} />);
    
    expect(getByText('Test Budget')).toBeInTheDocument();
    expect(getByText('$1000.00')).toBeInTheDocument();
  });
});
```

## Documentation

- Update README.md for user-facing changes
- Add inline code comments for complex logic
- Update API documentation for endpoint changes
- Add ADRs (Architecture Decision Records) for significant architectural changes

## Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
   - Build verification
   - Test execution
   - Linting
   - Security scanning

2. **Code Review**: At least one maintainer review required
   - Code quality
   - Test coverage
   - Documentation
   - Security considerations

3. **Merge**: Once approved and all checks pass

## Questions?

- Check existing [documentation](docs/)
- Search [existing issues](https://github.com/htekdev/budgeting-app/issues)
- Ask in [GitHub Discussions](https://github.com/htekdev/budgeting-app/discussions)

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to BudgetBuddy! 🎉
