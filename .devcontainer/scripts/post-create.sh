#!/bin/bash
set -e

echo "🚀 Running post-create setup..."

# Install SQL tools
bash .devcontainer/scripts/install-sql-tools.sh

# Navigate to workspace
cd /workspaces/${localWorkspaceFolderBasename}

# Restore backend dependencies
echo "📦 Restoring .NET dependencies..."
if [ -f "src/backend/BudgetBuddy.sln" ]; then
  dotnet restore src/backend/BudgetBuddy.sln
  echo "✅ .NET dependencies restored"
else
  echo "⚠️  Backend solution not found, skipping .NET restore"
fi

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
if [ -f "src/frontend/package.json" ]; then
  cd src/frontend
  npm ci
  cd ../..
  echo "✅ Frontend dependencies installed"
else
  echo "⚠️  Frontend package.json not found, skipping npm install"
fi

# Initialize database with retry logic
echo "🗄️  Initializing database..."
bash .devcontainer/scripts/init-db.sh || echo "⚠️  Database initialization skipped or failed - run manually if needed"

echo "✅ Post-create setup complete!"
echo ""
echo "🎉 Ready to code! Try these commands:"
echo "  - cd src/backend && dotnet run --project BudgetBuddy.Api"
echo "  - cd src/frontend && npm run dev"
echo "  - sqlcmd -S sqlserver -U sa -P 'YourStrong!Passw0rd'"
