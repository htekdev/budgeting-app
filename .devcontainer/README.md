# Dev Container Configuration

This directory contains the GitHub Codespaces and VS Code Dev Container configuration for BudgetBuddy.

## What's Included

- **devcontainer.json** - Main configuration file defining the development environment
- **docker-compose.devcontainer.yml** - Docker Compose override for the dev container
- **scripts/** - Setup and installation scripts

## Quick Start

### Using GitHub Codespaces

1. Go to the repository on GitHub
2. Click **Code** → **Codespaces** → **Create codespace**
3. Wait for the container to build and setup to complete
4. Start coding!

See [docs/runbooks/codespaces.md](../docs/runbooks/codespaces.md) for detailed instructions.

### Using VS Code Dev Containers Locally

1. Install **Docker Desktop** and **VS Code**
2. Install the **Dev Containers** extension in VS Code
3. Open this repository in VS Code
4. Click the green button in the lower-left corner
5. Select **Reopen in Container**

## What Gets Installed

### Tools & Runtimes
- **.NET SDK 8.0** - For backend development
- **Node.js LTS** - For frontend development
- **Terraform** - For infrastructure as code
- **Azure CLI** - For Azure deployments
- **GitHub CLI** - For GitHub operations
- **Docker** - Via docker-outside-of-docker feature
- **SQL Server tools** - sqlcmd and ODBC drivers

### VS Code Extensions
- GitHub Copilot & Copilot Chat
- C# Dev Kit
- Docker
- Terraform
- SQL Server (mssql)
- ESLint & Prettier
- GitHub Actions
- YAML

## Architecture

The dev container uses a multi-container setup:

```
┌─────────────────────────────────────┐
│  dev container (VS Code attaches)   │
│  - Ubuntu base                      │
│  - Dev tools installed              │
│  - Workspace mounted                │
│  - Connects to SQL Server           │
└─────────────────────────────────────┘
              ↓ network
┌─────────────────────────────────────┐
│  sqlserver container                │
│  - SQL Server 2022                  │
│  - Port 1433 exposed                │
│  - Persistent volume for data       │
└─────────────────────────────────────┘
```

The `dev` container shares the network with the `sqlserver` container, allowing seamless database access on `localhost:1433`.

## Post-Create Setup

When the container is created, `scripts/post-create.sh` automatically:

1. Installs SQL Server tools (sqlcmd, ODBC drivers)
2. Restores .NET dependencies (`dotnet restore`)
3. Installs frontend dependencies (`npm install`)
4. Waits for SQL Server to be ready
5. Applies EF Core database migrations
6. Seeds the database with sample data

This ensures you can start developing immediately without manual setup.

## Customization

### Adding Tools

Edit `devcontainer.json` and add features:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    }
  }
}
```

Browse available features at [containers.dev/features](https://containers.dev/features).

### Adding VS Code Extensions

Edit the `customizations.vscode.extensions` array in `devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "publisher.extension-id"
      ]
    }
  }
}
```

### Modifying Setup Scripts

Edit `scripts/post-create.sh` to add or modify setup steps. The script is idempotent, so it's safe to rebuild the container.

## Port Forwarding

Ports are automatically forwarded when services bind to them:

- **5173** - Frontend (Vite dev server)
- **5285** - Backend API  
- **1433** - SQL Server

In Codespaces, forwarded ports are accessible via auto-generated URLs. In local Dev Containers, they're accessible on `localhost`.

## Volumes

The dev container uses named volumes for caching:

- `devcontainer-nuget` - .NET NuGet packages
- `devcontainer-npm` - Node.js npm packages
- `devcontainer-vscode-extensions` - VS Code extensions

This speeds up container rebuilds by persisting downloaded packages.

## Rebuilding the Container

If you modify the dev container configuration:

**In Codespaces:**
1. Command Palette → **Codespaces: Rebuild Container**

**In VS Code locally:**
1. Command Palette → **Dev Containers: Rebuild Container**

This will rebuild the container with the new configuration.

## Troubleshooting

### Container Build Fails

Check the build logs in the terminal. Common issues:
- Network connectivity problems
- Docker daemon not running (local only)
- Insufficient disk space

### SQL Server Not Starting

The `sqlserver` container may take 10-30 seconds to start. Check:

```bash
docker ps
docker logs budgetbuddy-sql
```

### Ports Not Forwarding

Ensure the applications are actually binding to the ports. Check:

```bash
# Backend
cd src/backend/BudgetBuddy.Api && dotnet run

# Frontend
cd src/frontend && npm run dev
```

### Performance Issues

In Codespaces, you can upgrade to a more powerful machine type:
- Command Palette → **Codespaces: Change Machine Type**

## Resources

- [Dev Containers Documentation](https://containers.dev/)
- [GitHub Codespaces Documentation](https://docs.github.com/codespaces)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [BudgetBuddy Codespaces Guide](../docs/runbooks/codespaces.md)
