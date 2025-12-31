#!/bin/bash
set -e

echo "🗄️  Initializing SQL Server database..."

# Wait for SQL Server to be ready
max_attempts=30
attempt=0
until /opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P 'YourStrong!Passw0rd' -C -Q "SELECT 1" > /dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "❌ SQL Server did not become ready in time"
    exit 1
  fi
  echo "⏳ Waiting for SQL Server to be ready (attempt $attempt/$max_attempts)..."
  sleep 2
done

echo "✅ SQL Server is ready"

# Create database
echo "📝 Creating BudgetBuddy database..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P 'YourStrong!Passw0rd' -C -Q "
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BudgetBuddy')
BEGIN
  CREATE DATABASE BudgetBuddy;
  PRINT 'Database created successfully';
END
ELSE
BEGIN
  PRINT 'Database already exists';
END
"

# Run migrations if available
if [ -f "/workspaces/${localWorkspaceFolderBasename}/src/backend/BudgetBuddy.Api/BudgetBuddy.Api.csproj" ]; then
  echo "🔄 Running EF Core migrations..."
  cd /workspaces/${localWorkspaceFolderBasename}/src/backend
  dotnet ef database update --project BudgetBuddy.Api --startup-project BudgetBuddy.Api || echo "⚠️  Migrations not yet available"
fi

echo "✅ Database initialization complete"
