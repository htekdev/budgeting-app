#!/bin/bash
set -e

echo "========================================="
echo "BudgetBuddy Dev Container Setup"
echo "========================================="

# Navigate to workspace
cd /workspaces/budgeting-app

# Install SQL Server tools
echo ""
echo "Step 1: Installing SQL Server tools..."
bash .devcontainer/scripts/install-sql-tools.sh

# Restore backend dependencies
echo ""
echo "Step 2: Restoring .NET dependencies..."
cd src/backend
dotnet restore
cd ../..

# Install frontend dependencies
echo ""
echo "Step 3: Installing frontend dependencies..."
cd src/frontend
npm install
cd ../..

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
  cd src/backend
  
  # Set connection string for migration
  export ConnectionStrings__DefaultConnection="Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  
  # Apply migrations
  dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api || {
    echo "Migration failed, but continuing setup. You can run migrations manually later."
  }
  
  cd ../..
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
