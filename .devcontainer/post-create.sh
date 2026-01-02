#!/bin/bash
set -e

echo "🚀 Setting up BudgetBuddy development environment..."

# Install .NET tools
echo "📦 Installing .NET tools..."
dotnet tool install --global dotnet-ef || true

# Restore backend dependencies
echo "📦 Restoring backend dependencies..."
cd /workspaces/budgeting-app/src/backend
dotnet restore

# Build backend
echo "🔨 Building backend..."
dotnet build

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd /workspaces/budgeting-app/src/frontend
npm install

# Wait for SQL Server
echo "⏳ Waiting for SQL Server to be ready..."
sleep 30

# Run migrations
echo "🗄️ Running database migrations..."
cd /workspaces/budgeting-app/src/backend/BudgetBuddy.API
dotnet ef database update || echo "⚠️ Migrations will be applied on first run"

echo "✅ Development environment setup complete!"
echo ""
echo "🎯 Quick start commands:"
echo "  Backend:  cd src/backend/BudgetBuddy.API && dotnet run"
echo "  Frontend: cd src/frontend && npm run dev"
echo "  Tests:    cd src/backend && dotnet test"
echo ""
