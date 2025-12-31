---
applyTo:
  - "db/**/*.sql"
  - "**/*.sql"
---

# SQL Instructions

## Naming Conventions

- **Tables**: PascalCase singular (e.g., `Account` not `Accounts`)
- **Columns**: PascalCase (e.g., `AccountName`, `CreatedAt`)
- **Primary Keys**: `TableNameId` (e.g., `AccountId`)
- **Foreign Keys**: `FK_ChildTable_ParentTable`
- **Indexes**: `IX_TableName_ColumnName`
- **Check Constraints**: `CHK_TableName_ConditionDescription`
- **Unique Constraints**: `UQ_TableName_ColumnName`

## Data Types

- **Timestamps**: Use `DATETIME2` not `DATETIME`
- **Money**: Use `DECIMAL(18,2)` not `MONEY` or `FLOAT`
- **Text**: Use `NVARCHAR` for Unicode support
- **Boolean**: Use `BIT`
- **Primary Keys**: Use `INT IDENTITY(1,1)` for auto-increment

```sql
-- Good
CREATE TABLE Accounts (
    AccountId INT IDENTITY(1,1) PRIMARY KEY,
    AccountName NVARCHAR(200) NOT NULL,
    CurrentBalance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Bad
CREATE TABLE Accounts (
    id INT PRIMARY KEY,
    account_name VARCHAR(200),
    balance MONEY,
    created_at DATETIME DEFAULT GETDATE()
);
```

## Constraints

Always add appropriate constraints:

```sql
CREATE TABLE Transactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionType NVARCHAR(20) NOT NULL,
    
    -- Foreign key
    CONSTRAINT FK_Transactions_Accounts 
        FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    
    -- Check constraint
    CONSTRAINT CHK_Transactions_Amount 
        CHECK (Amount > 0),
    
    -- Check constraint for enum
    CONSTRAINT CHK_Transactions_TransactionType 
        CHECK (TransactionType IN ('Income', 'Expense', 'Transfer'))
);
```

## Indexes

Add indexes for:
- Foreign keys
- Common filter columns
- Date ranges
- Composite indexes for common query patterns

```sql
-- Single column indexes
CREATE INDEX IX_Transactions_AccountId 
    ON Transactions(AccountId);

CREATE INDEX IX_Transactions_TransactionDate 
    ON Transactions(TransactionDate);

-- Composite indexes for common queries
CREATE INDEX IX_Transactions_UserId_TransactionDate 
    ON Transactions(UserId, TransactionDate);

-- Covering index (includes non-key columns)
CREATE INDEX IX_Transactions_AccountId_TransactionDate_Amount 
    ON Transactions(AccountId, TransactionDate) 
    INCLUDE (Amount, TransactionType);
```

## Queries

- Use parameterized queries (prevents SQL injection)
- Avoid SELECT *
- Use EXISTS instead of IN for subqueries
- Use appropriate JOINs
- Filter as early as possible
- Use CTEs for complex queries

```sql
-- Good - parameterized, specific columns
SELECT t.TransactionId, t.Amount, t.TransactionDate, c.CategoryName
FROM Transactions t
INNER JOIN Categories c ON t.CategoryId = c.CategoryId
WHERE t.UserId = @UserId
  AND t.TransactionDate >= @StartDate
  AND t.TransactionDate < @EndDate
ORDER BY t.TransactionDate DESC;

-- Bad - SELECT *, no parameters, inefficient
SELECT *
FROM Transactions t
WHERE t.UserId IN (SELECT UserId FROM Users WHERE Email = 'user@example.com')
ORDER BY t.TransactionDate;
```

## Migrations

- Never modify existing migrations after merge
- One logical change per migration
- Test both up and down
- Include seed data updates if needed

```sql
-- Migration: Add IsActive column to Accounts
ALTER TABLE Accounts 
ADD IsActive BIT NOT NULL DEFAULT 1;

-- Add index
CREATE INDEX IX_Accounts_IsActive 
    ON Accounts(IsActive);

-- Update existing data
UPDATE Accounts 
SET IsActive = 1 
WHERE IsActive IS NULL;
```

## Breaking Changes

Use multi-step migrations:

```sql
-- Step 1: Add new column
ALTER TABLE Accounts 
ADD NewColumnName NVARCHAR(100) NULL;

-- Step 2: Migrate data
UPDATE Accounts 
SET NewColumnName = OldColumnName;

-- Step 3: Make NOT NULL
ALTER TABLE Accounts 
ALTER COLUMN NewColumnName NVARCHAR(100) NOT NULL;

-- Step 4 (next migration): Drop old column
ALTER TABLE Accounts 
DROP COLUMN OldColumnName;
```

## Performance

- Use appropriate indexes
- Avoid functions on indexed columns in WHERE clauses
- Use SET NOCOUNT ON in stored procedures
- Consider partitioning for large tables
- Use appropriate isolation levels

```sql
-- Bad - function on indexed column prevents index use
SELECT * FROM Transactions
WHERE YEAR(TransactionDate) = 2024;

-- Good - range query uses index
SELECT * FROM Transactions
WHERE TransactionDate >= '2024-01-01'
  AND TransactionDate < '2025-01-01';
```

## Security

- Never use dynamic SQL with string concatenation
- Use parameterized queries
- Grant minimum required permissions
- Use schemas for organization and security
- Encrypt sensitive data at rest

```sql
-- Bad - SQL injection vulnerability
DECLARE @sql NVARCHAR(MAX);
SET @sql = 'SELECT * FROM Accounts WHERE AccountId = ' + @AccountId;
EXEC sp_executesql @sql;

-- Good - parameterized
SELECT * FROM Accounts 
WHERE AccountId = @AccountId;
```
