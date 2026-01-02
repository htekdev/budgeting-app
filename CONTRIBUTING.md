# Contributing to BudgetBuddy

Thank you for your interest in contributing to BudgetBuddy! This document provides guidelines and instructions for contributing.

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in your interactions.

### Standards

**Examples of behavior that contributes to a positive environment:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include as many details as possible:

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g., Windows 11, macOS 14]
- Browser [e.g., Chrome 120, Firefox 121]
- .NET Version: [e.g., 10.0.1]
- Node Version: [e.g., 20.10.0]

**Additional context**
Add any other context about the problem.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

**Enhancement Template:**
```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Any other context or screenshots.
```

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our code style guidelines
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Run the self-audit**: `npm run self:audit`
6. **Submit a pull request**

## Development Process

### 1. Setup Development Environment

Follow the [Local Setup Guide](docs/runbooks/local-setup.md) to set up your development environment.

**Quick start:**
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/budgeting-app.git
cd budgeting-app

# Add upstream remote
git remote add upstream https://github.com/htekdev/budgeting-app.git

# Install dependencies
cd src/frontend && npm install
cd ../backend && dotnet restore
```

### 2. Create a Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
# OR
git checkout -b fix/your-bug-fix
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks

### 3. Make Changes

Follow our coding standards:

#### Backend (C#)

**Code Style:**
- Use C# 12 features (file-scoped namespaces, required properties)
- Follow [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- Use async/await for I/O operations
- Add XML documentation comments for public APIs

**Example:**
```csharp
/// <summary>
/// Gets a budget by its unique identifier.
/// </summary>
/// <param name="id">The budget identifier.</param>
/// <param name="db">The database context.</param>
/// <returns>The budget if found; otherwise, 404 Not Found.</returns>
app.MapGet("/api/budgets/{id:guid}", async (Guid id, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets.FindAsync(id);
    return budget is not null ? Results.Ok(budget) : Results.NotFound();
})
.WithName("GetBudgetById")
.WithTags("Budgets");
```

**Formatting:**
```bash
# Format code
dotnet format
```

#### Frontend (TypeScript/React)

**Code Style:**
- Use functional components with hooks
- Type everything (no `any`)
- Follow [Airbnb React/TypeScript Style Guide](https://github.com/airbnb/javascript/tree/master/react)
- Use meaningful variable and function names

**Example:**
```typescript
interface BudgetCardProps {
  budget: Budget;
  onEdit: (id: string) => void;
}

export function BudgetCard({ budget, onEdit }: BudgetCardProps) {
  const handleClick = () => {
    onEdit(budget.id);
  };

  return (
    <div className="budget-card" onClick={handleClick}>
      <h3>{budget.name}</h3>
      <p>${budget.totalAmount.toFixed(2)}</p>
    </div>
  );
}
```

**Linting:**
```bash
# Lint and fix
npm run lint:fix
```

### 4. Write Tests

All new features and bug fixes should include tests.

**Backend Tests (xUnit):**
```csharp
[Fact]
public async Task GetBudget_ReturnsOk_WhenBudgetExists()
{
    // Arrange
    var options = new DbContextOptionsBuilder<BudgetBuddyDbContext>()
        .UseInMemoryDatabase(databaseName: "TestDb")
        .Options;
    
    using var context = new BudgetBuddyDbContext(options);
    var budget = new Budget { Id = Guid.NewGuid(), Name = "Test" };
    context.Budgets.Add(budget);
    await context.SaveChangesAsync();
    
    // Act
    var result = await GetBudgetEndpoint(budget.Id, context);
    
    // Assert
    Assert.IsType<Ok<Budget>>(result);
}
```

**Frontend Tests (Vitest):**
```typescript
describe('BudgetCard', () => {
  it('renders budget information', () => {
    const budget = { id: '1', name: 'Test Budget', totalAmount: 1000 };
    render(<BudgetCard budget={budget} onEdit={() => {}} />);
    
    expect(screen.getByText('Test Budget')).toBeInTheDocument();
    expect(screen.getByText('$1000.00')).toBeInTheDocument();
  });
});
```

**Run Tests:**
```bash
# Backend
cd src/backend
dotnet test

# Frontend
cd src/frontend
npm test
```

### 5. Commit Changes

Use [Conventional Commits](https://www.conventionalcommits.org/):

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(api): add endpoint to get monthly spending trends"
git commit -m "fix(ui): resolve budget card alignment issue"
git commit -m "docs: update API documentation with new endpoints"
git commit -m "test(budget): add unit tests for budget calculator"
```

### 6. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create PR on GitHub
# Go to https://github.com/htekdev/budgeting-app
# Click "Pull Requests" > "New Pull Request"
```

**Pull Request Template:**
```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] All tests pass
- [ ] Self-audit passes (`npm run self:audit`)
- [ ] No new warnings

## Related Issues
Fixes #(issue number)

## Screenshots (if applicable)
Add screenshots of UI changes.

## Additional Notes
Any additional information.
```

## Code Review Process

### What We Look For

1. **Functionality**: Does it work as intended?
2. **Tests**: Are there adequate tests?
3. **Code Quality**: Is it readable and maintainable?
4. **Documentation**: Is it properly documented?
5. **Performance**: Are there any performance concerns?
6. **Security**: Are there any security issues?

### Review Timeline

- Initial review within 2-3 business days
- Follow-up reviews within 1-2 business days
- Aim to merge within 1 week of submission

### Addressing Feedback

- Be open to feedback
- Make requested changes
- Push updates to the same branch
- Reply to comments when addressed

## Using GitHub Copilot Agents

This project has custom Copilot agents to help with development:

**@backend_expert** - For C# backend tasks
```
@backend_expert add a new endpoint to filter transactions by date range
```

**@frontend_expert** - For React/TypeScript frontend tasks
```
@frontend_expert create a component to display budget progress with a progress bar
```

**@devops_expert** - For infrastructure and CI/CD tasks
```
@devops_expert optimize the Docker build process to reduce image size
```

See [AGENTS.md](AGENTS.md) for detailed usage guide.

## Project Structure

Understanding the project structure:

```
budgeting-app/
├── .devcontainer/          # Codespaces configuration
├── .github/
│   ├── agents/            # Custom Copilot agents
│   ├── instructions/      # Path-scoped instructions
│   ├── skills/            # Agent skills
│   └── workflows/         # GitHub Actions CI/CD
├── docs/
│   ├── architecture/      # System design docs
│   └── runbooks/          # Operational guides
├── infrastructure/
│   └── terraform/         # Infrastructure as Code
├── src/
│   ├── backend/          # .NET backend
│   │   ├── BudgetBuddy.API/
│   │   ├── BudgetBuddy.Domain/
│   │   ├── BudgetBuddy.Infrastructure/
│   │   └── BudgetBuddy.API.Tests/
│   └── frontend/         # React frontend
└── scripts/              # Utility scripts
```

## Style Guides

### Git Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests after the first line

### C# Style Guide

- Follow [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- Use PascalCase for classes, methods, properties
- Use camelCase for local variables, parameters
- Use _camelCase for private fields

### TypeScript/React Style Guide

- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use PascalCase for components
- Use camelCase for functions, variables
- Use UPPER_CASE for constants

## Documentation

Good documentation is crucial:

- **Code Comments**: Explain why, not what
- **README**: Keep updated with new features
- **API Docs**: Document all public endpoints
- **Runbooks**: Add operational procedures
- **Architecture Docs**: Document design decisions

## Questions?

- 💬 [GitHub Discussions](https://github.com/htekdev/budgeting-app/discussions)
- 🐛 [Issue Tracker](https://github.com/htekdev/budgeting-app/issues)
- 📧 Contact maintainers

## Recognition

Contributors will be recognized in:
- [README.md Contributors section](README.md)
- Release notes
- Project documentation

Thank you for contributing to BudgetBuddy! 🎉
