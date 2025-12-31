# Database Schema and Migrations

This directory contains the SQL Server database schema and migration scripts for BudgetBuddy.

## Directory Structure

```
db/
├── schema/
│   ├── 001_create_tables.sql    # Core table definitions
│   ├── 002_indexes.sql          # Performance indexes
│   └── 003_seed_data.sql        # Sample data for local dev
├── migrations/
│   └── (EF Core migrations generated here)
└── README.md
```

## Database Schema Overview

### Core Tables

1. **Users** - User accounts (auth-ready)
2. **Accounts** - Financial accounts (checking, savings, credit)
3. **Categories** - Income/expense categories with hierarchy support
4. **Transactions** - All financial transactions (income, expense, transfer)
5. **Budgets** - Monthly category budgets
6. **RecurringTransactions** - Scheduled recurring transactions
7. **Goals** - Savings goals with progress tracking
8. **AuditEvents** - Complete audit trail

### Entity Relationships

- Users → Accounts (1:N)
- Users → Categories (1:N)
- Categories → Categories (parent/child)
- Accounts → Transactions (1:N)
- Categories → Transactions (1:N)
- Categories → Budgets (1:N)
- Accounts → RecurringTransactions (1:N)
- Users → Goals (1:N)

## Local Development

### Using Docker Compose

The easiest way to run the database locally:

```bash
docker compose up sqlserver
```

This starts SQL Server 2022 in a container with:
- Port: 1433
- SA Password: YourStrong@Passw0rd
- Database: BudgetBuddy (created automatically by backend on startup)

### Manual Schema Application

If you need to manually apply the schema:

```bash
# Connect to SQL Server
sqlcmd -S localhost,1433 -U sa -P 'YourStrong@Passw0rd'

# Create database
CREATE DATABASE BudgetBuddy;
GO

# Apply schema scripts in order
:r db/schema/001_create_tables.sql
:r db/schema/002_indexes.sql
:r db/schema/003_seed_data.sql
```

Or using a SQL client (Azure Data Studio, SSMS, DBeaver):
1. Connect to localhost:1433 with sa/YourStrong@Passw0rd
2. Create BudgetBuddy database
3. Execute scripts in order: 001, 002, 003

## Migration Strategy

### Entity Framework Core Migrations

The backend uses EF Core Code-First with migrations. The schema scripts in `/db/schema/` are the source of truth for understanding the database structure.

**Generate a new migration:**
```bash
cd src/backend
dotnet ef migrations add MigrationName --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

**Apply migrations:**
```bash
dotnet ef database update --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api
```

**Migrations are automatically applied on application startup in Development mode.**

### CI/CD Pipeline

In production:
1. Migrations are generated in development
2. Reviewed in PRs
3. Applied during deployment via `dotnet ef database update` in CI/CD pipeline
4. Rollback capability via EF Core migration history

## Schema Design Principles

1. **Audit Trail**: All tables have CreatedAt/UpdatedAt; AuditEvents tracks changes
2. **Soft Deletes**: IsActive flags instead of hard deletes where appropriate
3. **Constraints**: Foreign keys, check constraints, unique constraints enforced
4. **Indexes**: Covering indexes for common query patterns (date ranges, user filters)
5. **Data Types**: DECIMAL(18,2) for money, DATETIME2 for timestamps, NVARCHAR for text
6. **Normalization**: 3NF normalized with denormalization only where performance requires

## Common Queries

### Get transactions for a month
```sql
SELECT t.*, c.CategoryName, a.AccountName
FROM Transactions t
INNER JOIN Categories c ON t.CategoryId = c.CategoryId
INNER JOIN Accounts a ON t.AccountId = a.AccountId
WHERE t.UserId = @UserId
  AND t.TransactionDate >= @MonthStart
  AND t.TransactionDate < @MonthEnd
ORDER BY t.TransactionDate DESC;
```

### Budget vs Actual
```sql
SELECT 
    b.CategoryId,
    c.CategoryName,
    b.BudgetAmount,
    ISNULL(SUM(t.Amount), 0) AS ActualAmount,
    b.BudgetAmount - ISNULL(SUM(t.Amount), 0) AS Variance
FROM Budgets b
INNER JOIN Categories c ON b.CategoryId = c.CategoryId
LEFT JOIN Transactions t ON t.CategoryId = b.CategoryId 
    AND t.UserId = b.UserId
    AND t.TransactionDate >= b.BudgetMonth
    AND t.TransactionDate < DATEADD(MONTH, 1, b.BudgetMonth)
    AND t.TransactionType = 'Expense'
WHERE b.UserId = @UserId
  AND b.BudgetMonth = @Month
GROUP BY b.CategoryId, c.CategoryName, b.BudgetAmount;
```

## Seed Data

The `003_seed_data.sql` script provides:
- Demo user (demo@budgetbuddy.local)
- Standard expense/income categories
- 3 sample accounts
- 3 months of sample transactions
- Sample recurring transactions
- Current month budgets
- 2 sample goals

This seed data allows immediate testing and demo of the application.

## Schema Changes

When making schema changes:

1. Update schema scripts in `/db/schema/` (source of truth)
2. Generate corresponding EF Core migration
3. Test migration up and down
4. Update this README if needed
5. Add ADR in `/docs/decisions/` for significant changes

## Performance Considerations

- **Indexes**: Carefully designed for transaction queries, reports, and date ranges
- **Partitioning**: Consider partitioning Transactions table by date for large datasets
- **Archival**: Consider archival strategy for old audit events and transactions
- **Connection Pooling**: Configured in backend connection string

## Security

- **No secrets in code**: Connection strings use environment variables
- **Parameterized queries**: EF Core and Dapper use parameterized queries to prevent SQL injection
- **Least privilege**: Application uses dedicated SQL user (not sa) in production
- **Encryption**: TLS for connections, transparent data encryption (TDE) in Azure SQL

## Troubleshooting

**Connection failed:**
- Ensure SQL Server container is running: `docker compose ps`
- Check connection string in backend configuration
- Verify firewall allows port 1433

**Schema out of sync:**
- Drop database and recreate: `docker compose down -v && docker compose up`
- Or manually drop/recreate BudgetBuddy database

**Missing seed data:**
- Re-run 003_seed_data.sql
- Or restart backend with fresh database

## References

- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)
- [SQL Server in Docker](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
