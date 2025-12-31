# GitHub Codespaces Quick Start Guide

This guide explains how to develop BudgetBuddy using GitHub Codespaces with VS Code in the browser or locally.

## What is GitHub Codespaces?

GitHub Codespaces provides a complete development environment in the cloud. When you open this repository in Codespaces, you get:
- A full Ubuntu development container with all required tools pre-installed
- SQL Server running automatically in a separate container
- VS Code with all recommended extensions pre-installed
- Port forwarding for easy access to frontend, backend, and database

## Quick Start

### 1. Create a Codespace

**From GitHub.com:**
1. Navigate to the repository: https://github.com/htekdev/budgeting-app
2. Click the green **Code** button
3. Select the **Codespaces** tab
4. Click **Create codespace on main** (or your branch)

**From VS Code Desktop:**
1. Install the **GitHub Codespaces** extension
2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Select **Codespaces: Create New Codespace**
4. Choose this repository and branch

### 2. Wait for Setup

The first time you create a Codespace, it will:
- Build the dev container (~2-3 minutes)
- Install SQL Server tools
- Restore .NET dependencies
- Install npm packages
- Apply database migrations
- Set up SQL Server with seed data

You'll see progress in the terminal. **Watch for "Setup Complete!" message.**

### 3. Start Development

Once setup is complete, you're ready to code!

## Running the Application

### Running the Backend API

1. **Open a terminal** (Terminal → New Terminal)
2. Navigate to the API project:
   ```bash
   cd src/backend/BudgetBuddy.Api
   ```
3. Run the API:
   ```bash
   dotnet run
   ```
4. The API will start on **http://localhost:5285**
5. Swagger UI is available at **http://localhost:5285/swagger**

**Tip:** Codespaces will automatically forward port 5285. Click the **Ports** tab in the bottom panel to see all forwarded ports and open them in your browser.

### Running the Frontend

1. **Open a second terminal** (click the + button in the terminal panel)
2. Navigate to the frontend:
   ```bash
   cd src/frontend
   ```
3. Run the Vite dev server:
   ```bash
   npm run dev
   ```
4. The frontend will start on **http://localhost:5173**
5. Codespaces will automatically forward the port and provide a URL

**Tip:** When the frontend starts, you'll see a notification with a button to open the forwarded URL.

### Debugging the Backend in VS Code

1. Open `src/backend/BudgetBuddy.Api/Program.cs`
2. Set a breakpoint (click in the gutter next to a line number)
3. Press **F5** or go to **Run → Start Debugging**
4. Select **.NET Core Launch (web)** if prompted
5. The debugger will attach and hit your breakpoints

### Running Both Services Together

For convenience, you can use VS Code tasks or split terminals.

## Connecting to SQL Server

SQL Server is running in a separate container and is accessible from the dev container on `localhost:1433`.

**Connection Details:**
- **Server:** `localhost` or `localhost,1433`
- **Port:** `1433`
- **Authentication:** SQL Server Authentication
- **Username:** `sa`
- **Password:** `YourStrong@Passw0rd`
- **Database:** `BudgetBuddy`
- **Trust Server Certificate:** Yes (required for local development)

### Using sqlcmd (Command Line)

The `sqlcmd` tool is pre-installed in your dev container.

**Connect to SQL Server:**
```bash
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C
```

The `-C` flag trusts the server certificate.

**Run a query:**
```bash
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -d BudgetBuddy -Q "SELECT COUNT(*) FROM Transactions"
```

**Interactive mode:**
```bash
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -d BudgetBuddy
```

Then type queries:
```sql
SELECT * FROM Accounts;
GO
```

Type `EXIT` to quit.

### Using VS Code MSSQL Extension

The **SQL Server (mssql)** extension is pre-installed.

**Create a connection:**

1. Click the **SQL Server** icon in the left sidebar (database icon)
2. Click **Add Connection** (+ button)
3. Fill in the connection details:
   - **Server name:** `localhost`
   - **Database name:** `BudgetBuddy` (or leave blank to connect to server)
   - **Authentication Type:** SQL Login
   - **User name:** `sa`
   - **Password:** `YourStrong@Passw0rd`
   - **Save Password:** Yes (in your Codespace only)
   - **Profile Name:** `BudgetBuddy Local`
   - **Trust Server Certificate:** Yes
4. Click **Connect**

**Run queries:**

1. Right-click on your connection and select **New Query**
2. Type your SQL query:
   ```sql
   SELECT TOP 10 * FROM Transactions ORDER BY TransactionDate DESC;
   ```
3. Highlight the query and press **Ctrl+Shift+E** (or **Cmd+Shift+E** on Mac) to execute

**Browse database:**

- Expand your connection in the SQL Server panel
- Expand **Databases → BudgetBuddy → Tables**
- Right-click a table and select **Select Top 1000** to view data

## Database Migrations

### Applying Migrations

Migrations are automatically applied during Codespace setup. If you need to apply them manually:

```bash
cd src/backend
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

### Creating a New Migration

When you modify entity models:

```bash
cd src/backend
dotnet ef migrations add MigrationName --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

### Resetting the Database

If you need to start fresh:

```bash
cd src/backend
dotnet ef database drop --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

## Port Forwarding

GitHub Codespaces automatically forwards ports when applications bind to them.

**Ports used by BudgetBuddy:**
- **5173** - Frontend (Vite dev server)
- **5285** - Backend API
- **1433** - SQL Server

## Troubleshooting

### SQL Server Not Ready

If SQL Server hasn't started when you try to connect:

1. **Check container status:**
   ```bash
   docker ps
   ```

2. **Check logs:**
   ```bash
   docker logs budgetbuddy-sql
   ```

3. **Restart SQL Server:**
   ```bash
   docker restart budgetbuddy-sql
   ```

### Dev Container Rebuild Needed

If you modify `.devcontainer/devcontainer.json`:

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Select **Codespaces: Rebuild Container**

## Tips and Best Practices

1. **Commit frequently** - Codespaces are ephemeral
2. **Use VS Code tasks** - For common development workflows
3. **Stop unused Codespaces** - To conserve resources

## Next Steps

1. Explore the codebase
2. Read `.github/copilot-instructions.md` for conventions
3. Try GitHub Copilot Chat for code assistance

---

**Happy coding in the cloud! ☁️**
