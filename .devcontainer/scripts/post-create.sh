#!/bin/bash
set -e

echo "========================================="
echo "BudgetBuddy Dev Container Setup"
echo "========================================="

# Get the workspace directory (where the repo root is)
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspaces/budgeting-app}"

# If we're in a subdirectory of workspaces, find the repo root
if [ ! -f "$WORKSPACE_DIR/.devcontainer/devcontainer.json" ] && [ -f "$(pwd)/.devcontainer/devcontainer.json" ]; then
  WORKSPACE_DIR="$(pwd)"
fi

echo "Working directory: $WORKSPACE_DIR"

# Navigate to workspace
cd "$WORKSPACE_DIR"

# Install SQL Server tools
echo ""
echo "Step 1: Installing SQL Server tools..."
bash /tmp/devcontainer-scripts/install-sql-tools.sh

# Restore backend dependencies
echo ""
echo "Step 2: Restoring .NET dependencies..."
cd "$WORKSPACE_DIR/src/backend"
dotnet restore
cd "$WORKSPACE_DIR"

# Install frontend dependencies
echo ""
echo "Step 3: Installing frontend dependencies..."
cd "$WORKSPACE_DIR/src/frontend"
npm install
cd "$WORKSPACE_DIR"

# Wait for SQL Server to be ready
echo ""
echo "Step 4: Waiting for SQL Server to be ready..."
max_attempts=30
attempt=0
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT 1" > /dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ $attempt -eq $max_attempts ]; then
    echo "SQL Server did not start in time. You may need to run database setup manually."
    break
  fi
  echo "Waiting for SQL Server... (attempt $attempt/$max_attempts)"
  sleep 2
done

if [ $attempt -lt $max_attempts ]; then
  echo "SQL Server is ready!"
  
  # Apply EF Core migrations
  echo ""
  echo "Step 5: Applying database migrations..."
  cd "$WORKSPACE_DIR/src/backend"
  
  # Set connection string for migration
  export ConnectionStrings__DefaultConnection="Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  
  # Apply migrations
  dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api || {
    echo "Migration failed, but continuing setup. You can run migrations manually later."
  }
  
  cd "$WORKSPACE_DIR"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run the backend API:"
echo "     cd src/backend/BudgetBuddy.Api && dotnet run"
echo ""
echo "  2. Run the frontend (in a new terminal):"
echo "     cd src/frontend && npm run dev"
echo ""
echo "  3. Connect to SQL Server:"
echo "     Server: localhost"
echo "     Port: 1433"
echo "     User: sa"
echo "     Password: YourStrong@Passw0rd"
echo ""
echo "See docs/runbooks/codespaces.md for more details."
echo ""
