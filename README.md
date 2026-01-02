# BudgetBuddy - Full-Stack Budgeting Application

BudgetBuddy is a comprehensive personal finance and budgeting application built to showcase GitHub Copilot across the entire Software Development Lifecycle (SDLC). This project demonstrates a **verification-first approach** where criteria are defined and validation scripts are created BEFORE any application code.

## 🏗️ Architecture

### Technology Stack

- **Backend**: ASP.NET Core Web API (.NET 10)
- **Frontend**: React 18+ with TypeScript (Vite)
- **Database**: SQL Server 2022 (containerized)
- **Infrastructure**: Terraform (Azure)
- **Development**: Docker Compose + GitHub Codespaces
- **CI/CD**: GitHub Actions

### Project Structure

```
budgeting-app/
├── .github/
│   ├── copilot-instructions.md       # Repository-wide Copilot instructions
│   ├── instructions/                  # Path-scoped instructions
│   │   ├── backend.instructions.md
│   │   └── frontend.instructions.md
│   ├── agents/                        # Custom Copilot agents
│   │   └── test-specialist.agent.md
│   ├── skills/                        # Copilot skills
│   │   └── budget-calculation/
│   │       └── SKILL.md
│   └── workflows/                     # GitHub Actions
│       └── ci.yml
├── .devcontainer/                     # Dev Container config
│   └── devcontainer.json
├── .verification/                     # Verification scripts
│   ├── master-verify.sh              # Single command to validate all
│   ├── verify-copilot-files.sh
│   ├── verify-project-structure.sh
│   ├── verify-docker.sh
│   ├── verify-terraform.sh
│   └── verify-ci.sh
├── backend/                           # .NET 10 Web API
│   ├── Controllers/
│   ├── Models/
│   ├── Data/
│   ├── Services/
│   ├── Program.cs
│   └── Dockerfile
├── frontend/                          # React + TypeScript
│   ├── src/
│   │   ├── components/
│   │   ├── services/
│   │   └── types/
│   ├── vite.config.ts
│   └── Dockerfile
├── terraform/                         # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── docker-compose.yml                 # Local development
├── AGENTS.md                          # Project-wide agent instructions
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Node.js 20+](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Terraform](https://www.terraform.io/downloads) (optional, for infrastructure)

### Local Development with Docker Compose

1. **Clone the repository**
   ```bash
   git clone https://github.com/htekdev/budgeting-app.git
   cd budgeting-app
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - OpenAPI/Swagger: http://localhost:5000/openapi

4. **Stop services**
   ```bash
   docker-compose down
   ```

### Development with GitHub Codespaces

1. Click the "Code" button and select "Open with Codespaces"
2. Wait for the container to build and start
3. All services will be automatically configured and running

### Manual Setup (Without Docker)

#### Backend

```bash
cd backend
dotnet restore
dotnet run
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

#### Database

You'll need a local SQL Server instance. Update the connection string in `backend/appsettings.json`.

## 🔍 Verification-First Approach

This project follows a unique **verification-first** methodology:

1. **PHASE 1: Exhaustive Grounding** - Research and document all criteria from official sources
2. **PHASE 2: Build Verification Scripts** - Create validation before any application code
3. **PHASE 3: Build Application Code** - Develop application to meet pre-defined criteria
4. **PHASE 4: Verification & Self-Audit** - Run comprehensive validation

### Running Verifications

```bash
# Run all verifications
./.verification/master-verify.sh

# Run individual verifications
./.verification/verify-copilot-files.sh
./.verification/verify-project-structure.sh
./.verification/verify-docker.sh
./.verification/verify-terraform.sh
./.verification/verify-ci.sh
```

All verifications must pass before code is considered complete.

## 🤖 GitHub Copilot Customization

This project extensively uses GitHub Copilot customization features:

### Repository-wide Instructions
- `.github/copilot-instructions.md` - General coding standards for the entire project

### Path-scoped Instructions
- `.github/instructions/backend.instructions.md` - .NET-specific guidelines
- `.github/instructions/frontend.instructions.md` - React/TypeScript guidelines

### Custom Agents
- `.github/agents/test-specialist.agent.md` - Specialized testing agent

### Agent Skills
- `.github/skills/budget-calculation/SKILL.md` - Budget calculation logic patterns

### Agent Instructions
- `AGENTS.md` - Project context and workflows for Copilot agents

## 🏢 Infrastructure Deployment

### Azure Deployment with Terraform

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Review planned changes**
   ```bash
   terraform plan \
     -var="sql_admin_username=YOUR_USERNAME" \
     -var="sql_admin_password=YOUR_PASSWORD"
   ```

3. **Apply infrastructure**
   ```bash
   terraform apply \
     -var="sql_admin_username=YOUR_USERNAME" \
     -var="sql_admin_password=YOUR_PASSWORD"
   ```

## 🔄 CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push and pull request:

- ✅ Backend build and test (.NET 10)
- ✅ Frontend build and test (React + TypeScript)
- ✅ Docker image builds
- ✅ Terraform validation

## 📊 Features

### Current Features

- **Budget Management**: Create and track budgets by category
- **Category System**: Organize expenses and income
- **Transaction Tracking**: Record and categorize transactions
- **RESTful API**: Well-documented API endpoints
- **Database Persistence**: SQL Server with Entity Framework Core

### Planned Features

- Authentication and authorization
- Budget calculation and alerts
- Spending reports and visualizations
- Budget goals and savings tracking
- Multi-user support
- Mobile responsive design

## 🧪 Testing

### Backend Tests
```bash
cd backend
dotnet test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📝 API Documentation

When running locally, access the OpenAPI documentation at:
- http://localhost:5000/openapi

### Example Endpoints

- `GET /api/budgets` - Get all budgets
- `GET /api/budgets/{id}` - Get specific budget
- `POST /api/budgets` - Create new budget

## 🛡️ Security

- No hardcoded secrets (verified by scripts)
- Environment variables for sensitive data
- SQL injection prevention via parameterized queries
- Input validation on all endpoints
- Secure password hashing (when auth is implemented)

## 📚 Documentation

- [Verification Scripts README](./.verification/README.md)
- [Backend Development Guide](./.github/instructions/backend.instructions.md)
- [Frontend Development Guide](./.github/instructions/frontend.instructions.md)
- [Agent Instructions](./AGENTS.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run verification scripts: `./.verification/master-verify.sh`
5. Commit your changes
6. Push to your fork
7. Open a Pull Request

All PRs must pass verification scripts and CI checks.

## 📄 License

This project is for demonstration purposes as part of the GitHub Copilot showcase.

## 🙏 Acknowledgments

Built to demonstrate:
- GitHub Copilot's capabilities across the SDLC
- Verification-first development methodology
- Modern full-stack development practices
- Infrastructure as Code
- Containerized development environments

---

**Note**: This is a demonstration project showcasing best practices for using GitHub Copilot with custom instructions, agents, and skills across a complete application lifecycle.
