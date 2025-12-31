-- BudgetBuddy Database Schema - Indexes
-- This script creates indexes for optimal query performance

-- Indexes on Users
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_Username ON Users(Username);

-- Indexes on Accounts
CREATE INDEX IX_Accounts_UserId ON Accounts(UserId);
CREATE INDEX IX_Accounts_UserId_IsActive ON Accounts(UserId, IsActive) WHERE IsActive = 1;

-- Indexes on Categories
CREATE INDEX IX_Categories_UserId ON Categories(UserId);
CREATE INDEX IX_Categories_UserId_Type ON Categories(UserId, Type);
CREATE INDEX IX_Categories_ParentCategoryId ON Categories(ParentCategoryId);

-- Indexes on Transactions (critical for reporting)
CREATE INDEX IX_Transactions_UserId ON Transactions(UserId);
CREATE INDEX IX_Transactions_AccountId ON Transactions(AccountId);
CREATE INDEX IX_Transactions_CategoryId ON Transactions(CategoryId);
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
CREATE INDEX IX_Transactions_UserId_TransactionDate ON Transactions(UserId, TransactionDate);
CREATE INDEX IX_Transactions_UserId_CategoryId_TransactionDate ON Transactions(UserId, CategoryId, TransactionDate);
CREATE INDEX IX_Transactions_AccountId_TransactionDate ON Transactions(AccountId, TransactionDate);

-- Indexes on Budgets
CREATE INDEX IX_Budgets_UserId ON Budgets(UserId);
CREATE INDEX IX_Budgets_CategoryId ON Budgets(CategoryId);
CREATE INDEX IX_Budgets_Month ON Budgets(Month);
CREATE INDEX IX_Budgets_UserId_Month ON Budgets(UserId, Month);

-- Indexes on Recurring Transactions
CREATE INDEX IX_RecurringTransactions_UserId ON RecurringTransactions(UserId);
CREATE INDEX IX_RecurringTransactions_NextOccurrence ON RecurringTransactions(NextOccurrence) WHERE IsActive = 1;
CREATE INDEX IX_RecurringTransactions_UserId_IsActive ON RecurringTransactions(UserId, IsActive);

-- Indexes on Goals
CREATE INDEX IX_Goals_UserId ON Goals(UserId);
CREATE INDEX IX_Goals_UserId_IsCompleted ON Goals(UserId, IsCompleted);

-- Indexes on Audit Events
CREATE INDEX IX_AuditEvents_UserId ON AuditEvents(UserId);
CREATE INDEX IX_AuditEvents_EntityType_EntityId ON AuditEvents(EntityType, EntityId);
CREATE INDEX IX_AuditEvents_Timestamp ON AuditEvents(Timestamp);

PRINT 'Indexes created successfully';
