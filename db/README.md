# Database

This directory contains the database schema and migration scripts for the BudgetBuddy application.

## Structure

- **`schema/`** - SQL scripts for creating tables, indexes, and seed data
  - `001_create_tables.sql` - Creates all database tables
  - `002_indexes.sql` - Creates indexes for optimal query performance
  - `003_seed_data.sql` - Inserts sample data for development

- **`migrations/`** - EF Core migration files (generated)
  - Entity Framework Core is used as the primary migration tool
  - Migrations are auto-generated from the domain models

## Database Schema

### Core Tables

- **Users** - User accounts
- **Accounts** - Financial accounts (checking, savings, credit)
- **Categories** - Income and expense categories with hierarchy support
- **Transactions** - All financial transactions (income, expense, transfer)
- **Budgets** - Monthly budget allocations per category
- **RecurringTransactions** - Scheduled recurring transactions
- **Goals** - Savings goals with progress tracking
- **AuditEvents** - Audit trail for all entity changes

### Relationships

```
Users (1) -> (*) Accounts
Users (1) -> (*) Categories
Users (1) -> (*) Transactions
Users (1) -> (*) Budgets
Users (1) -> (*) RecurringTransactions
Users (1) -> (*) Goals

Accounts (1) -> (*) Transactions
Categories (1) -> (*) Transactions
Categories (1) -> (*) Budgets
Categories (1) -> (*) RecurringTransactions
Categories (1) -> (*) Categories (parent-child)
```

## Migration Approach

This project uses **Entity Framework Core** migrations as the primary approach:

### Creating Migrations

```bash
# From the src/backend directory
cd src/backend

# Create a new migration
dotnet ef migrations add MigrationName --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api

# Update database
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

### Initial Setup

For a fresh database, you can either:

1. **Use EF Migrations** (recommended):
   ```bash
   dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
   ```

2. **Run SQL scripts manually**:
   ```bash
   sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -d BudgetBuddy -i db/schema/001_create_tables.sql
   sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -d BudgetBuddy -i db/schema/002_indexes.sql
   sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -d BudgetBuddy -i db/schema/003_seed_data.sql
   ```

### Connection String

**Local Development:**
```
Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True
```

**Docker Compose:**
```
Server=sqlserver;Database=BudgetBuddy;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True
```

**Codespaces:**
```
Server=sqlserver;Database=BudgetBuddy;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True
```

## Backup & Restore

### Backup

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "BACKUP DATABASE BudgetBuddy TO DISK = '/var/opt/mssql/backup/BudgetBuddy.bak'"
```

### Restore

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "RESTORE DATABASE BudgetBuddy FROM DISK = '/var/opt/mssql/backup/BudgetBuddy.bak' WITH REPLACE"
```

## Performance Considerations

- Indexes are optimized for common query patterns (see `002_indexes.sql`)
- Transactions table has composite indexes for report queries
- Date-based queries are indexed for fast filtering
- Foreign keys ensure referential integrity

## Testing

Integration tests use Testcontainers to spin up a SQL Server instance:

```bash
cd src/backend
dotnet test --filter Category=Integration
```

## Troubleshooting

### Connection Issues

```bash
# Check if SQL Server is running
docker ps | grep sqlserver

# Test connection
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "SELECT @@VERSION"
```

### Migration Issues

```bash
# List migrations
dotnet ef migrations list --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api

# Remove last migration (if not applied)
dotnet ef migrations remove --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api

# Generate SQL script for a migration
dotnet ef migrations script --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```
