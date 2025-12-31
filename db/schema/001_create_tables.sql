-- BudgetBuddy Database Schema - Tables
-- This script creates all the core tables for the budgeting application

-- Users table
CREATE TABLE Users (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  Username NVARCHAR(100) NOT NULL UNIQUE,
  Email NVARCHAR(255) NOT NULL UNIQUE,
  PasswordHash NVARCHAR(500) NOT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  IsActive BIT NOT NULL DEFAULT 1
);

-- Accounts table (checking, savings, credit cards)
CREATE TABLE Accounts (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  Name NVARCHAR(200) NOT NULL,
  Type NVARCHAR(50) NOT NULL CHECK (Type IN ('Checking', 'Savings', 'Credit', 'Investment', 'Cash')),
  Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
  Currency NVARCHAR(3) NOT NULL DEFAULT 'USD',
  IsActive BIT NOT NULL DEFAULT 1,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- Categories table (for income and expense categorization)
CREATE TABLE Categories (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  Name NVARCHAR(200) NOT NULL,
  Type NVARCHAR(50) NOT NULL CHECK (Type IN ('Income', 'Expense')),
  ParentCategoryId INT NULL,
  Icon NVARCHAR(50) NULL,
  Color NVARCHAR(7) NULL,
  IsActive BIT NOT NULL DEFAULT 1,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_Categories_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
  CONSTRAINT FK_Categories_ParentCategory FOREIGN KEY (ParentCategoryId) REFERENCES Categories(Id)
);

-- Transactions table
CREATE TABLE Transactions (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  AccountId INT NOT NULL,
  CategoryId INT NULL,
  Type NVARCHAR(50) NOT NULL CHECK (Type IN ('Income', 'Expense', 'Transfer')),
  Amount DECIMAL(18,2) NOT NULL,
  Description NVARCHAR(500) NULL,
  TransactionDate DATE NOT NULL,
  ToAccountId INT NULL, -- For transfers
  Notes NVARCHAR(1000) NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
  CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(Id),
  CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
  CONSTRAINT FK_Transactions_ToAccount FOREIGN KEY (ToAccountId) REFERENCES Accounts(Id)
);

-- Budgets table (monthly budget per category)
CREATE TABLE Budgets (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  CategoryId INT NOT NULL,
  Month DATE NOT NULL, -- First day of the month
  Amount DECIMAL(18,2) NOT NULL,
  Notes NVARCHAR(500) NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
  CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
  CONSTRAINT UQ_Budget_UserCategoryMonth UNIQUE (UserId, CategoryId, Month)
);

-- Recurring Transactions table (rent, subscriptions, salary)
CREATE TABLE RecurringTransactions (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  AccountId INT NOT NULL,
  CategoryId INT NULL,
  Type NVARCHAR(50) NOT NULL CHECK (Type IN ('Income', 'Expense', 'Transfer')),
  Amount DECIMAL(18,2) NOT NULL,
  Description NVARCHAR(500) NOT NULL,
  Frequency NVARCHAR(50) NOT NULL CHECK (Frequency IN ('Daily', 'Weekly', 'BiWeekly', 'Monthly', 'Quarterly', 'Yearly')),
  StartDate DATE NOT NULL,
  EndDate DATE NULL,
  NextOccurrence DATE NOT NULL,
  ToAccountId INT NULL,
  IsActive BIT NOT NULL DEFAULT 1,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_RecurringTransactions_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
  CONSTRAINT FK_RecurringTransactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(Id),
  CONSTRAINT FK_RecurringTransactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
  CONSTRAINT FK_RecurringTransactions_ToAccount FOREIGN KEY (ToAccountId) REFERENCES Accounts(Id)
);

-- Goals table (savings goals)
CREATE TABLE Goals (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  Name NVARCHAR(200) NOT NULL,
  TargetAmount DECIMAL(18,2) NOT NULL,
  CurrentAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
  TargetDate DATE NULL,
  Description NVARCHAR(1000) NULL,
  IsCompleted BIT NOT NULL DEFAULT 0,
  CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_Goals_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- Audit Events table (change history)
CREATE TABLE AuditEvents (
  Id INT IDENTITY(1,1) PRIMARY KEY,
  UserId INT NOT NULL,
  EntityType NVARCHAR(100) NOT NULL,
  EntityId INT NOT NULL,
  Action NVARCHAR(50) NOT NULL CHECK (Action IN ('Create', 'Update', 'Delete')),
  Changes NVARCHAR(MAX) NULL, -- JSON format
  Timestamp DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  CONSTRAINT FK_AuditEvents_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);

PRINT 'Tables created successfully';
