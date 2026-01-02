# BudgetBuddy 💰

A full-stack personal budgeting application showcasing GitHub Copilot capabilities across the entire Software Development Lifecycle (SDLC). Built with modern technologies and best practices, BudgetBuddy demonstrates how AI-assisted development can accelerate building production-ready applications.

[![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![React](https://img.shields.io/badge/React-18+-61DAFB?logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5+-3178C6?logo=typescript)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

- 📊 **Budget Management**: Create and manage multiple budgets with custom time periods
- 🏷️ **Category Tracking**: Organize expenses and income by customizable categories
- 💸 **Transaction Recording**: Log all financial transactions with rich metadata
- 📈 **Real-time Analytics**: Track spending patterns and budget progress
- 🎨 **Modern UI**: Responsive React interface with TypeScript
- 🔒 **Secure API**: .NET 10 backend with health checks and structured logging
- 🐳 **Containerized**: Full Docker Compose setup for local development
- ☁️ **Cloud-Ready**: Infrastructure as Code with Terraform for Azure
- 🤖 **AI-Powered Development**: Custom Copilot agents and instructions

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌───────────────┐
│   React +   │─────▶│  ASP.NET     │─────▶│  SQL Server   │
│ TypeScript  │      │  Core Web    │      │   Database    │
│  (Vite)     │◀─────│     API      │◀─────│               │
└─────────────┘      └──────────────┘      └───────────────┘
  Frontend            Backend (.NET 10)      Persistence
  Port: 3000          Port: 5000             Port: 1433
```

### Technology Stack

**Backend**:
- .NET 10 ASP.NET Core Web API (Minimal APIs)
- Entity Framework Core 10 (SQL Server)
- Serilog for structured logging
- FluentValidation for request validation
- Swagger/OpenAPI for API documentation

**Frontend**:
- React 18 with TypeScript
- Vite for fast builds
- Axios for HTTP requests
- Generated TypeScript client from OpenAPI spec
- CSS Modules for styling

**Infrastructure**:
- Docker & Docker Compose for local development
- Terraform for Azure infrastructure
- GitHub Actions for CI/CD
- GitHub Codespaces ready with devcontainer

**Database**:
- SQL Server 2022
- Entity Framework Core migrations
- Seed data for development

## 🚀 Quick Start

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Node.js 20+](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)

### Option 1: GitHub Codespaces (Recommended)

1. Click the green "Code" button on GitHub
2. Select "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for the environment to initialize (automated setup)

The devcontainer will automatically:
- Install all dependencies
- Start SQL Server
- Build the backend
- Install frontend packages
- Apply database migrations

### Option 2: Local Development with Docker Compose

```bash
# Clone the repository
git clone https://github.com/htekdev/budgeting-app.git
cd budgeting-app

# Start all services (backend, frontend, database)
docker-compose up -d

# Wait for services to start (about 60 seconds)
# Backend API will be at http://localhost:5000
# Frontend will be at http://localhost:3000
# Swagger UI at http://localhost:5000/swagger
```

### Option 3: Local Development without Docker

**Backend**:
```bash
# Navigate to backend
cd src/backend

# Restore dependencies
dotnet restore

# Update connection string in appsettings.json to point to your SQL Server

# Run migrations
cd BudgetBuddy.API
dotnet ef database update

# Run the API
dotnet run

# API will start at https://localhost:5001 or http://localhost:5000
```

**Frontend**:
```bash
# Navigate to frontend
cd src/frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Frontend will start at http://localhost:3000
```

## 📚 Documentation

- **[Architecture Overview](docs/architecture/system-design.md)** - System design and component interactions
- **[Database Schema](docs/architecture/database-schema.md)** - Entity relationship diagram and schema details
- **[Local Setup Guide](docs/runbooks/local-setup.md)** - Detailed setup instructions
- **[Deployment Guide](docs/runbooks/deployment.md)** - How to deploy to Azure
- **[Verification Guide](docs/runbooks/verification.md)** - Testing and validation procedures
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute to the project
- **[Copilot Agents](AGENTS.md)** - Using custom AI agents for development

## 🤖 GitHub Copilot Integration

This project includes comprehensive Copilot customization:

### Custom Agents
- **@backend_expert**: .NET and C# backend specialist
- **@frontend_expert**: React and TypeScript expert
- **@devops_expert**: Infrastructure and deployment specialist

### Custom Instructions
- Repository-wide instructions in `.github/copilot-instructions.md`
- Path-scoped instructions for backend (`backend.instructions.md`)
- Path-scoped instructions for frontend (`frontend.instructions.md`)

### Agent Skills
- **budget-calculator**: Financial calculation logic
- **data-seeder**: Generate realistic test data
- **terraform-validator**: Infrastructure validation

**Example Usage**:
```
@backend_expert create an endpoint to get monthly spending trends

@frontend_expert create a chart component to visualize transaction history

@devops_expert set up a GitHub Actions workflow for automated deployment
```

## 🧪 Testing

### Backend Tests
```bash
cd src/backend
dotnet test
```

### Frontend Tests
```bash
cd src/frontend
npm test
```

### Integration Tests
```bash
cd src/backend
dotnet test --filter Category=Integration
```

## 📊 API Documentation

When running locally, access the interactive API documentation:
- **Swagger UI**: http://localhost:5000/swagger
- **OpenAPI Spec**: http://localhost:5000/openapi/v1.json

### Example Endpoints

```http
GET    /api/budgets              # List all budgets (paginated)
GET    /api/budgets/{id}          # Get budget by ID
POST   /api/budgets               # Create new budget
PUT    /api/budgets/{id}          # Update budget
DELETE /api/budgets/{id}          # Delete budget

GET    /api/budgets/{id}/transactions    # Get budget transactions
POST   /api/transactions                  # Create transaction

GET    /api/budgets/{id}/categories      # Get budget categories
POST   /api/categories                    # Create category

GET    /health                            # Health check endpoint
```

## 🔧 Development

### Project Structure
```
budgeting-app/
├── .devcontainer/              # Codespaces configuration
├── .github/
│   ├── agents/                 # Custom Copilot agents
│   ├── instructions/           # Path-scoped instructions
│   ├── skills/                 # Reusable agent skills
│   ├── workflows/              # GitHub Actions CI/CD
│   └── copilot-instructions.md # Repository-wide instructions
├── docs/                       # Documentation
│   ├── architecture/           # System design docs
│   └── runbooks/              # Operational guides
├── infrastructure/
│   └── terraform/             # Infrastructure as Code
├── src/
│   ├── backend/               # .NET backend
│   │   ├── BudgetBuddy.API/           # Web API project
│   │   ├── BudgetBuddy.Domain/        # Domain models
│   │   ├── BudgetBuddy.Infrastructure/ # Data access
│   │   └── BudgetBuddy.API.Tests/     # Tests
│   └── frontend/              # React frontend
│       ├── src/
│       │   ├── components/    # React components
│       │   ├── api/          # Generated API client
│       │   ├── hooks/        # Custom hooks
│       │   └── pages/        # Page components
│       └── public/           # Static assets
├── docker-compose.yml         # Local dev environment
├── AGENTS.md                  # Agent usage guide
└── README.md                  # This file
```

### Database Migrations

**Create a new migration**:
```bash
cd src/backend/BudgetBuddy.API
dotnet ef migrations add YourMigrationName
```

**Apply migrations**:
```bash
dotnet ef database update
```

**Revert last migration**:
```bash
dotnet ef migrations remove
```

### Code Quality

**Backend Linting**:
```bash
dotnet format
```

**Frontend Linting**:
```bash
npm run lint
npm run lint:fix
```

## 🚢 Deployment

### Deploy to Azure

The infrastructure can be deployed using Terraform:

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan -var-file="prod.tfvars"

# Apply changes
terraform apply -var-file="prod.tfvars"
```

### CI/CD Pipeline

GitHub Actions workflows automatically:
- Build and test on every push
- Run security scans (CodeQL, dependency review)
- Validate Terraform configurations
- Deploy to Azure on release tags (manual approval required)

## 🔒 Security

- Secrets are never committed to source control
- Connection strings use environment variables
- SQL injection prevented via Entity Framework parameterization
- CORS configured for specific origins
- HTTPS redirection enabled
- Rate limiting implemented

See [SECURITY.md](SECURITY.md) for reporting security issues.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of Conduct
- Development workflow
- Pull request process
- Code style guidelines

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [GitHub Copilot](https://github.com/features/copilot)
- Demonstrates AI-assisted full-stack development
- Showcases modern .NET and React patterns
- Example of comprehensive DevOps practices

## 📞 Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/htekdev/budgeting-app/issues)
- 💬 [Discussions](https://github.com/htekdev/budgeting-app/discussions)

---

**Built with ❤️ and 🤖 GitHub Copilot**
