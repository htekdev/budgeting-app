# Quick Reference Guide

Essential commands and workflows for BudgetBuddy development.

## Daily Development Workflow

### Starting Work

```bash
# 1. Pull latest changes
git pull origin main

# 2. Start local environment
docker-compose up -d

# 3. Check services are healthy
docker-compose ps

# 4. Open your editor
code .
```

### Backend Development

```bash
# Navigate to backend
cd backend/BudgetBuddy.Api

# Run in watch mode (auto-reload)
dotnet watch run

# Run specific endpoint
curl http://localhost:5000/api/budgets

# View Swagger
open http://localhost:5000/swagger
```

### Frontend Development

```bash
# Navigate to frontend
cd frontend

# Start dev server
npm run dev

# Frontend will be at http://localhost:5173
# Auto-reloads on file changes
```

### Making Changes

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make your changes...

# Test your changes
dotnet test  # Backend
npm test     # Frontend

# Commit with conventional commit message
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/my-feature
```

## Common Commands

### Git

```bash
# Create branch
git checkout -b feature/feature-name

# Commit changes
git add .
git commit -m "type: description"

# Update from main
git pull origin main --rebase

# Push changes
git push origin feature-name

# View status
git status

# View diff
git diff

# View log
git log --oneline
```

### Backend (.NET)

```bash
# Restore packages
dotnet restore

# Build
dotnet build

# Run
dotnet run

# Watch mode (auto-reload)
dotnet watch run

# Test
dotnet test

# Clean
dotnet clean

# Format code
dotnet format

# Add package
dotnet add package PackageName

# Entity Framework
dotnet ef migrations add MigrationName
dotnet ef database update
dotnet ef database drop
dotnet ef migrations list
dotnet ef migrations remove
```

### Frontend (Node/NPM)

```bash
# Install dependencies
npm install

# Dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Run tests
npm test

# Run tests in watch mode
npm test:watch

# Update dependencies
npm update

# Check for outdated packages
npm outdated
```

### Docker

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Rebuild images
docker-compose build

# Rebuild without cache
docker-compose build --no-cache

# Restart service
docker-compose restart backend

# View running containers
docker-compose ps

# Execute command in container
docker-compose exec backend bash

# Remove volumes
docker-compose down -v
```

### Database

```bash
# Connect to SQL Server (Docker)
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong@Passw0rd" -C

# Create migration
cd backend/BudgetBuddy.Api
dotnet ef migrations add MigrationName

# Apply migrations
dotnet ef database update

# Rollback migration
dotnet ef database update PreviousMigrationName

# Generate SQL script
dotnet ef migrations script

# Drop database
dotnet ef database drop

# List migrations
dotnet ef migrations list
```

### Azure CLI

```bash
# Login
az login

# Set subscription
az account set --subscription <subscription-id>

# View resources
az resource list --resource-group rg-budgetbuddy-prod

# View logs
az webapp log tail --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# Restart app
az webapp restart --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod

# View app settings
az webapp config appsettings list \
  --name app-budgetbuddy-backend-prod \
  --resource-group rg-budgetbuddy-prod
```

### Terraform

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format code
terraform fmt

# Validate configuration
terraform validate

# View outputs
terraform output

# View state
terraform state list

# Import existing resource
terraform import <resource_type>.<name> <azure_resource_id>
```

## Code Snippets

### Create New Controller

```csharp
using Microsoft.AspNetCore.Mvc;
using BudgetBuddy.Api.Data;
using BudgetBuddy.Api.Models;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MyController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<MyController> _logger;

    public MyController(BudgetBuddyDbContext context, ILogger<MyController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MyModel>>> GetAll()
    {
        _logger.LogInformation("Fetching all items");
        var items = await _context.MyModels.ToListAsync();
        return Ok(items);
    }
}
```

### Create New React Component

```typescript
import type { MyType } from '../types';

interface MyComponentProps {
  data: MyType;
  onAction: (id: number) => void;
}

export function MyComponent({ data, onAction }: MyComponentProps) {
  const handleClick = () => {
    onAction(data.id);
  };

  return (
    <div className="my-component">
      <h3>{data.name}</h3>
      <button onClick={handleClick}>Action</button>
    </div>
  );
}
```

### Create Custom Hook

```typescript
import { useState, useEffect } from 'react';
import type { MyType } from '../types';
import { myService } from '../services/api';

export function useMyData(id: number) {
  const [data, setData] = useState<MyType | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const result = await myService.getData(id);
        setData(result);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  return { data, loading, error };
}
```

## Environment Variables

### Backend (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

### Frontend (.env)

```bash
VITE_API_URL=http://localhost:5000/api
```

## API Endpoints Quick Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/budgets` | Get all budgets |
| GET | `/api/budgets/{id}` | Get budget by ID |
| POST | `/api/budgets` | Create budget |
| PUT | `/api/budgets/{id}` | Update budget |
| DELETE | `/api/budgets/{id}` | Delete budget |
| GET | `/api/transactions` | Get all transactions |
| GET | `/api/transactions/{id}` | Get transaction by ID |
| POST | `/api/transactions` | Create transaction |
| PUT | `/api/transactions/{id}` | Update transaction |
| DELETE | `/api/transactions/{id}` | Delete transaction |
| GET | `/health` | Health check |
| GET | `/swagger` | API documentation |

## Keyboard Shortcuts (VS Code)

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + P` | Quick file open |
| `Ctrl/Cmd + Shift + P` | Command palette |
| `Ctrl/Cmd + B` | Toggle sidebar |
| `Ctrl/Cmd + `` ` | Toggle terminal |
| `F5` | Start debugging |
| `Shift + F5` | Stop debugging |
| `Ctrl/Cmd + Shift + F` | Search in files |
| `Alt + Up/Down` | Move line up/down |
| `Ctrl/Cmd + D` | Select next occurrence |

## Testing

### Backend Unit Test

```csharp
using Xunit;
using Moq;
using Microsoft.Extensions.Logging;

public class MyControllerTests
{
    [Fact]
    public async Task GetAll_ReturnsOk()
    {
        // Arrange
        var mockContext = new Mock<BudgetBuddyDbContext>();
        var mockLogger = new Mock<ILogger<MyController>>();
        var controller = new MyController(mockContext.Object, mockLogger.Object);

        // Act
        var result = await controller.GetAll();

        // Assert
        Assert.IsType<OkObjectResult>(result.Result);
    }
}
```

### Frontend Component Test

```typescript
import { render, screen } from '@testing-library/react';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders correctly', () => {
    const data = { id: 1, name: 'Test' };
    render(<MyComponent data={data} onAction={vi.fn()} />);
    
    expect(screen.getByText('Test')).toBeInTheDocument();
  });
});
```

## Debugging

### Backend Debugging

1. Set breakpoint in VS Code
2. Press F5 or click Debug → Start Debugging
3. Select ".NET Core Launch (web)"
4. Make API request
5. Code will pause at breakpoint

### Frontend Debugging

1. Open Chrome DevTools (F12)
2. Go to Sources tab
3. Find your file
4. Set breakpoint
5. Interact with app
6. Code will pause at breakpoint

### Docker Debugging

```bash
# View logs
docker-compose logs -f servicename

# Execute commands in container
docker-compose exec backend bash

# Inside container
cd /app
ls -la
cat appsettings.json
```

## Performance Monitoring

### Backend

```csharp
// Add timing to controller
var stopwatch = Stopwatch.StartNew();
// ... operation ...
stopwatch.Stop();
_logger.LogInformation("Operation took {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
```

### Frontend

```typescript
// Use React DevTools Profiler
// Or console.time
console.time('operation');
// ... operation ...
console.timeEnd('operation');
```

## GitHub Copilot Tips

```bash
# Use comments to guide Copilot
// Create a function that validates email addresses

// Generate test for the following function

// Implement error handling for this API call

# Use Copilot Chat
# Ask: "How do I add authentication to this API?"
# Ask: "Explain this code"
# Ask: "Refactor this to be more efficient"
```

## Useful Links

- [Backend API Docs](http://localhost:5000/swagger)
- [Frontend](http://localhost:5173)
- [Repository](https://github.com/htekdev/budgeting-app)
- [Issues](https://github.com/htekdev/budgeting-app/issues)
- [.NET Docs](https://docs.microsoft.com/en-us/dotnet/)
- [React Docs](https://react.dev/)
- [Azure Docs](https://docs.microsoft.com/en-us/azure/)

## Getting Help

1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review [Architecture Docs](ARCHITECTURE.md)
3. Ask in team chat
4. Create GitHub issue
5. Use GitHub Copilot agents (see [AGENTS.md](../AGENTS.md))

---

**Pro Tip:** Save this guide as a browser bookmark for quick access!
