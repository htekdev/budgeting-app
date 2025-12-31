-- BudgetBuddy Database Schema
-- Version: 1.0
-- Description: Core tables for budgeting application

-- Users table (auth-ready, single-user by default in local dev)
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- Accounts table (checking, savings, credit)
CREATE TABLE Accounts (
    AccountId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    AccountName NVARCHAR(200) NOT NULL,
    AccountType NVARCHAR(50) NOT NULL, -- Checking, Savings, Credit, Investment
    CurrentBalance DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    Currency NVARCHAR(3) NOT NULL DEFAULT 'USD',
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CHK_AccountType CHECK (AccountType IN ('Checking', 'Savings', 'Credit', 'Investment'))
);

-- Categories table (income/expense categories)
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryType NVARCHAR(20) NOT NULL, -- Income, Expense
    ParentCategoryId INT NULL,
    Icon NVARCHAR(50) NULL,
    Color NVARCHAR(7) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Categories_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CHK_CategoryType CHECK (CategoryType IN ('Income', 'Expense')),
    CONSTRAINT UQ_Category_User_Name UNIQUE (UserId, CategoryName)
);

-- Transactions table (income, expense, transfer)
CREATE TABLE Transactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    AccountId INT NOT NULL,
    CategoryId INT NULL,
    TransactionType NVARCHAR(20) NOT NULL, -- Income, Expense, Transfer
    Amount DECIMAL(18, 2) NOT NULL,
    TransactionDate DATE NOT NULL,
    Description NVARCHAR(500) NULL,
    Notes NVARCHAR(MAX) NULL,
    ToAccountId INT NULL, -- For transfers
    RecurringTransactionId INT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT FK_Transactions_ToAccounts FOREIGN KEY (ToAccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT CHK_TransactionType CHECK (TransactionType IN ('Income', 'Expense', 'Transfer')),
    CONSTRAINT CHK_Amount CHECK (Amount > 0)
);

-- Budgets table (monthly category budgets)
CREATE TABLE Budgets (
    BudgetId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CategoryId INT NOT NULL,
    BudgetMonth DATE NOT NULL, -- First day of the month
    BudgetAmount DECIMAL(18, 2) NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Budget_User_Category_Month UNIQUE (UserId, CategoryId, BudgetMonth),
    CONSTRAINT CHK_BudgetAmount CHECK (BudgetAmount >= 0)
);

-- RecurringTransactions table (rent, subscriptions, salary)
CREATE TABLE RecurringTransactions (
    RecurringTransactionId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    AccountId INT NOT NULL,
    CategoryId INT NULL,
    TransactionType NVARCHAR(20) NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    Frequency NVARCHAR(20) NOT NULL, -- Daily, Weekly, Biweekly, Monthly, Quarterly, Yearly
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    LastGeneratedDate DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_RecurringTransactions_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_RecurringTransactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT FK_RecurringTransactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CHK_RecurringType CHECK (TransactionType IN ('Income', 'Expense')),
    CONSTRAINT CHK_Frequency CHECK (Frequency IN ('Daily', 'Weekly', 'Biweekly', 'Monthly', 'Quarterly', 'Yearly')),
    CONSTRAINT CHK_RecurringAmount CHECK (Amount > 0)
);

-- Goals table (savings goals)
CREATE TABLE Goals (
    GoalId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    GoalName NVARCHAR(200) NOT NULL,
    TargetAmount DECIMAL(18, 2) NOT NULL,
    CurrentAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    TargetDate DATE NULL,
    AccountId INT NULL, -- Optional linked account
    IsCompleted BIT NOT NULL DEFAULT 0,
    CompletedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Goals_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Goals_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT CHK_TargetAmount CHECK (TargetAmount > 0),
    CONSTRAINT CHK_CurrentAmount CHECK (CurrentAmount >= 0)
);

-- AuditEvents table (audit trail for all changes)
CREATE TABLE AuditEvents (
    AuditEventId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    EntityType NVARCHAR(50) NOT NULL, -- Account, Transaction, Budget, etc.
    EntityId INT NOT NULL,
    Action NVARCHAR(20) NOT NULL, -- Create, Update, Delete
    Changes NVARCHAR(MAX) NULL, -- JSON of changed fields
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    Timestamp DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_AuditEvents_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CHK_Action CHECK (Action IN ('Create', 'Update', 'Delete'))
);

GO
