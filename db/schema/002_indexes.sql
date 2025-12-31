-- Indexes for BudgetBuddy
-- Performance optimization for common queries

-- Users indexes
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_IsActive ON Users(IsActive);

-- Accounts indexes
CREATE INDEX IX_Accounts_UserId ON Accounts(UserId);
CREATE INDEX IX_Accounts_UserId_IsActive ON Accounts(UserId, IsActive);
CREATE INDEX IX_Accounts_AccountType ON Accounts(AccountType);

-- Categories indexes
CREATE INDEX IX_Categories_UserId ON Categories(UserId);
CREATE INDEX IX_Categories_CategoryType ON Categories(CategoryType);
CREATE INDEX IX_Categories_UserId_IsActive ON Categories(UserId, IsActive);
CREATE INDEX IX_Categories_ParentCategoryId ON Categories(ParentCategoryId);

-- Transactions indexes (critical for reports)
CREATE INDEX IX_Transactions_UserId ON Transactions(UserId);
CREATE INDEX IX_Transactions_AccountId ON Transactions(AccountId);
CREATE INDEX IX_Transactions_CategoryId ON Transactions(CategoryId);
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
CREATE INDEX IX_Transactions_UserId_TransactionDate ON Transactions(UserId, TransactionDate);
CREATE INDEX IX_Transactions_UserId_AccountId_TransactionDate ON Transactions(UserId, AccountId, TransactionDate);
CREATE INDEX IX_Transactions_UserId_CategoryId_TransactionDate ON Transactions(UserId, CategoryId, TransactionDate);
CREATE INDEX IX_Transactions_TransactionType ON Transactions(TransactionType);
CREATE INDEX IX_Transactions_RecurringTransactionId ON Transactions(RecurringTransactionId);

-- Budgets indexes
CREATE INDEX IX_Budgets_UserId ON Budgets(UserId);
CREATE INDEX IX_Budgets_CategoryId ON Budgets(CategoryId);
CREATE INDEX IX_Budgets_BudgetMonth ON Budgets(BudgetMonth);
CREATE INDEX IX_Budgets_UserId_BudgetMonth ON Budgets(UserId, BudgetMonth);

-- RecurringTransactions indexes
CREATE INDEX IX_RecurringTransactions_UserId ON RecurringTransactions(UserId);
CREATE INDEX IX_RecurringTransactions_AccountId ON RecurringTransactions(AccountId);
CREATE INDEX IX_RecurringTransactions_IsActive ON RecurringTransactions(IsActive);
CREATE INDEX IX_RecurringTransactions_StartDate ON RecurringTransactions(StartDate);
CREATE INDEX IX_RecurringTransactions_LastGeneratedDate ON RecurringTransactions(LastGeneratedDate);

-- Goals indexes
CREATE INDEX IX_Goals_UserId ON Goals(UserId);
CREATE INDEX IX_Goals_AccountId ON Goals(AccountId);
CREATE INDEX IX_Goals_IsCompleted ON Goals(IsCompleted);
CREATE INDEX IX_Goals_TargetDate ON Goals(TargetDate);

-- AuditEvents indexes
CREATE INDEX IX_AuditEvents_UserId ON AuditEvents(UserId);
CREATE INDEX IX_AuditEvents_EntityType_EntityId ON AuditEvents(EntityType, EntityId);
CREATE INDEX IX_AuditEvents_Timestamp ON AuditEvents(Timestamp);
CREATE INDEX IX_AuditEvents_UserId_Timestamp ON AuditEvents(UserId, Timestamp);

GO
