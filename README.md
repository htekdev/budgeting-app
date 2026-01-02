# 💰 BudgetBuddy

A comprehensive full-stack budgeting application showcasing GitHub Copilot capabilities across the entire Software Development Lifecycle (SDLC).

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![.NET](https://img.shields.io/badge/.NET-10.0-purple.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)
![React](https://img.shields.io/badge/React-19.0-61dafb.svg)

## 🌟 Features

- **Budget Management**: Create and manage multiple budgets with custom time periods
- **Transaction Tracking**: Record income and expenses with categorization
- **Real-time Dashboard**: View budget summaries and spending analytics
- **Category Management**: Organize expenses into customizable categories
- **RESTful API**: Well-documented API with Swagger/OpenAPI
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Frontend  │────────▶│   Backend    │────────▶│  SQL Server │
│ React + TS  │  HTTP   │ ASP.NET Core │   EF    │  Database   │
│   (Vite)    │◀────────│   Web API    │◀────────│             │
└─────────────┘   JSON  └──────────────┘  Core   └─────────────┘
      │                        │
      │                        │
      ▼                        ▼
  ┌─────────────┐       ┌─────────────┐
  │   Nginx     │       │  App Insights│
  │  (Docker)   │       │  (Monitoring)│
  └─────────────┘       └─────────────┘
```

### Technology Stack

**Frontend:**
- React 19 with TypeScript
- Vite for build tooling
- CSS3 for styling
- Custom hooks for state management

**Backend:**
- ASP.NET Core 10 Web API
- Entity Framework Core 10
- SQL Server 2022
- Swagger/OpenAPI documentation

**Infrastructure:**
- Docker & Docker Compose
- Azure App Services
- Azure SQL Database
- Terraform for IaC
- GitHub Actions for CI/CD

**Development:**
- GitHub Codespaces
- Dev Containers
- GitHub Copilot

## 🚀 Quick Start

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Node.js 20+](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)

### Option 1: Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/htekdev/budgeting-app.git
cd budgeting-app

# Start all services
docker-compose up -d

# Wait for services to be healthy (~30 seconds)
docker-compose ps

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
# Swagger UI: http://localhost:5000/swagger
```

### Option 2: Local Development

**Backend:**
```bash
cd backend/BudgetBuddy.Api
dotnet restore
dotnet run
# API available at http://localhost:5000
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
# App available at http://localhost:5173
```

**Database:**
```bash
# Start SQL Server in Docker
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

### Option 3: GitHub Codespaces

1. Click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for the environment to build (~2-3 minutes)
3. Codespaces will automatically forward ports
4. Access the application through the forwarded ports

## 📚 Documentation

- **[API Documentation](docs/API.md)**: Complete API reference with examples
- **[Architecture Guide](docs/ARCHITECTURE.md)**: Detailed architecture documentation
- **[Deployment Guide](docs/DEPLOYMENT.md)**: Step-by-step deployment instructions
- **[Contributing Guide](CONTRIBUTING.md)**: How to contribute to this project
- **[Agent Documentation](AGENTS.md)**: GitHub Copilot agents and skills

## 🛠️ Development

### Project Structure

```
budgeting-app/
├── backend/
│   └── BudgetBuddy.Api/          # ASP.NET Core Web API
│       ├── Controllers/           # API Controllers
│       ├── Models/                # Domain Models
│       ├── Data/                  # DbContext & Migrations
│       └── DTOs/                  # Data Transfer Objects
├── frontend/
│   └── src/
│       ├── components/            # React Components
│       ├── services/              # API Services
│       ├── hooks/                 # Custom Hooks
│       └── types/                 # TypeScript Types
├── infrastructure/
│   └── terraform/                 # Infrastructure as Code
├── .github/
│   ├── workflows/                 # GitHub Actions
│   ├── agents/                    # Copilot Custom Agents
│   ├── skills/                    # Copilot Agent Skills
│   └── instructions/              # Path-scoped Instructions
├── .devcontainer/                 # Dev Container Configuration
└── docker-compose.yml             # Local Development Setup
```

### Building

**Backend:**
```bash
cd backend/BudgetBuddy.Api
dotnet build
```

**Frontend:**
```bash
cd frontend
npm run build
```

### Testing

**Backend:**
```bash
cd backend/BudgetBuddy.Api
dotnet test
```

**Frontend:**
```bash
cd frontend
npm test
```

### Linting

**Backend:**
```bash
dotnet format
```

**Frontend:**
```bash
npm run lint
```

## 🔒 Security

- **Input Validation**: All inputs are validated on both client and server
- **SQL Injection Prevention**: Parameterized queries via Entity Framework
- **CORS Configuration**: Properly configured CORS policy
- **Secret Management**: Environment variables for sensitive data
- **CodeQL Analysis**: Automated security scanning in CI/CD
- **Dependency Scanning**: Automated dependency vulnerability checks

See [SECURITY.md](SECURITY.md) for more details.

## 🚢 Deployment

### Azure (Recommended)

See the [deployment guide](.github/skills/deploy-azure.skill.md) for detailed instructions.

Quick deploy:
```bash
cd infrastructure/terraform
terraform init
terraform apply
```

### Other Platforms

The application can be deployed to any platform that supports:
- Docker containers
- .NET 10 runtime
- Node.js 20
- SQL Server

## 🤖 GitHub Copilot Integration

This repository showcases advanced GitHub Copilot features:

### Repository-wide Instructions
- `.github/copilot-instructions.md`: General project guidelines

### Path-scoped Instructions
- `.github/instructions/backend.instructions.md`: C# coding standards
- `.github/instructions/frontend.instructions.md`: TypeScript/React guidelines
- `.github/instructions/terraform.instructions.md`: Infrastructure standards

### Custom Agents
- **Code Review Agent**: Automated code review and suggestions
- **Testing Agent**: Generate comprehensive tests
- **Documentation Agent**: Create and maintain documentation

### Agent Skills
- Database Migration procedures
- API Debugging techniques
- Azure Deployment steps

See [AGENTS.md](AGENTS.md) for detailed usage.

## 📊 Monitoring & Observability

- **Health Checks**: `/health` endpoint for container orchestration
- **Structured Logging**: JSON-formatted logs for easy parsing
- **Application Insights**: Azure monitoring and analytics
- **Swagger UI**: Interactive API documentation

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linting
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [GitHub Copilot](https://github.com/features/copilot)
- Frontend scaffolded with [Vite](https://vitejs.dev/)
- Backend powered by [ASP.NET Core](https://dotnet.microsoft.com/apps/aspnet)
- Infrastructure managed with [Terraform](https://www.terraform.io/)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/htekdev/budgeting-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/htekdev/budgeting-app/discussions)
- **Documentation**: Check the `docs/` folder

## 🗺️ Roadmap

- [ ] User authentication with Azure AD B2C
- [ ] Budget sharing and collaboration
- [ ] Data export (CSV, PDF)
- [ ] Mobile app (React Native)
- [ ] Advanced analytics and reporting
- [ ] Multi-currency support
- [ ] Automated budget recommendations (AI)

---

Made with ❤️ and GitHub Copilot
