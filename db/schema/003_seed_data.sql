-- BudgetBuddy Database Schema - Seed Data
-- This script populates initial data for development and testing

-- Insert default user (for single-user local development)
INSERT INTO Users (Username, Email, PasswordHash, IsActive)
VALUES ('demo', 'demo@budgetbuddy.local', 'DEMO_HASH_NOT_FOR_PRODUCTION', 1);

DECLARE @DemoUserId INT = SCOPE_IDENTITY();

-- Insert default accounts
INSERT INTO Accounts (UserId, Name, Type, Balance, Currency)
VALUES 
  (@DemoUserId, 'Checking Account', 'Checking', 5000.00, 'USD'),
  (@DemoUserId, 'Savings Account', 'Savings', 15000.00, 'USD'),
  (@DemoUserId, 'Credit Card', 'Credit', -800.00, 'USD');

DECLARE @CheckingId INT = (SELECT Id FROM Accounts WHERE UserId = @DemoUserId AND Name = 'Checking Account');
DECLARE @SavingsId INT = (SELECT Id FROM Accounts WHERE UserId = @DemoUserId AND Name = 'Savings Account');
DECLARE @CreditId INT = (SELECT Id FROM Accounts WHERE UserId = @DemoUserId AND Name = 'Credit Card');

-- Insert default categories
-- Income categories
INSERT INTO Categories (UserId, Name, Type, Icon, Color)
VALUES 
  (@DemoUserId, 'Salary', 'Income', '💼', '#10b981'),
  (@DemoUserId, 'Freelance', 'Income', '💻', '#14b8a6'),
  (@DemoUserId, 'Investment', 'Income', '📈', '#06b6d4'),
  (@DemoUserId, 'Other Income', 'Income', '💰', '#22c55e');

-- Expense categories
INSERT INTO Categories (UserId, Name, Type, Icon, Color)
VALUES 
  (@DemoUserId, 'Housing', 'Expense', '🏠', '#ef4444'),
  (@DemoUserId, 'Transportation', 'Expense', '🚗', '#f97316'),
  (@DemoUserId, 'Food & Dining', 'Expense', '🍔', '#f59e0b'),
  (@DemoUserId, 'Utilities', 'Expense', '💡', '#eab308'),
  (@DemoUserId, 'Healthcare', 'Expense', '🏥', '#84cc16'),
  (@DemoUserId, 'Entertainment', 'Expense', '🎬', '#06b6d4'),
  (@DemoUserId, 'Shopping', 'Expense', '🛍️', '#8b5cf6'),
  (@DemoUserId, 'Personal', 'Expense', '👤', '#ec4899'),
  (@DemoUserId, 'Education', 'Expense', '📚', '#3b82f6'),
  (@DemoUserId, 'Insurance', 'Expense', '🛡️', '#6366f1'),
  (@DemoUserId, 'Savings', 'Expense', '💎', '#14b8a6'),
  (@DemoUserId, 'Other Expenses', 'Expense', '📦', '#64748b');

-- Get category IDs
DECLARE @SalaryId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Salary');
DECLARE @HousingId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Housing');
DECLARE @FoodId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Food & Dining');
DECLARE @TransportId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Transportation');
DECLARE @UtilitiesId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Utilities');
DECLARE @EntertainmentId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Entertainment');
DECLARE @ShoppingId INT = (SELECT Id FROM Categories WHERE UserId = @DemoUserId AND Name = 'Shopping');

-- Insert sample transactions (last 30 days)
DECLARE @Today DATE = CAST(GETDATE() AS DATE);

INSERT INTO Transactions (UserId, AccountId, CategoryId, Type, Amount, Description, TransactionDate)
VALUES 
  -- Income
  (@DemoUserId, @CheckingId, @SalaryId, 'Income', 5000.00, 'Monthly Salary', DATEADD(DAY, -25, @Today)),
  
  -- Expenses
  (@DemoUserId, @CheckingId, @HousingId, 'Expense', 1500.00, 'Rent Payment', DATEADD(DAY, -24, @Today)),
  (@DemoUserId, @CreditId, @FoodId, 'Expense', 85.50, 'Grocery Shopping', DATEADD(DAY, -23, @Today)),
  (@DemoUserId, @CheckingId, @UtilitiesId, 'Expense', 120.00, 'Electric Bill', DATEADD(DAY, -22, @Today)),
  (@DemoUserId, @CreditId, @FoodId, 'Expense', 45.00, 'Restaurant Dinner', DATEADD(DAY, -20, @Today)),
  (@DemoUserId, @CheckingId, @TransportId, 'Expense', 60.00, 'Gas', DATEADD(DAY, -18, @Today)),
  (@DemoUserId, @CreditId, @ShoppingId, 'Expense', 120.00, 'Clothing', DATEADD(DAY, -15, @Today)),
  (@DemoUserId, @CreditId, @EntertainmentId, 'Expense', 50.00, 'Movie Tickets', DATEADD(DAY, -12, @Today)),
  (@DemoUserId, @CreditId, @FoodId, 'Expense', 95.00, 'Grocery Shopping', DATEADD(DAY, -10, @Today)),
  (@DemoUserId, @CheckingId, @TransportId, 'Expense', 55.00, 'Gas', DATEADD(DAY, -8, @Today)),
  (@DemoUserId, @CreditId, @FoodId, 'Expense', 35.00, 'Lunch', DATEADD(DAY, -5, @Today)),
  (@DemoUserId, @CreditId, @FoodId, 'Expense', 78.00, 'Grocery Shopping', DATEADD(DAY, -3, @Today)),
  (@DemoUserId, @CreditId, @EntertainmentId, 'Expense', 15.99, 'Netflix Subscription', DATEADD(DAY, -2, @Today));

-- Insert monthly budgets for current month
DECLARE @CurrentMonth DATE = DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 1);

INSERT INTO Budgets (UserId, CategoryId, Month, Amount)
VALUES 
  (@DemoUserId, @HousingId, @CurrentMonth, 1500.00),
  (@DemoUserId, @FoodId, @CurrentMonth, 600.00),
  (@DemoUserId, @TransportId, @CurrentMonth, 300.00),
  (@DemoUserId, @UtilitiesId, @CurrentMonth, 200.00),
  (@DemoUserId, @EntertainmentId, @CurrentMonth, 150.00),
  (@DemoUserId, @ShoppingId, @CurrentMonth, 300.00);

-- Insert recurring transactions
INSERT INTO RecurringTransactions (UserId, AccountId, CategoryId, Type, Amount, Description, Frequency, StartDate, NextOccurrence)
VALUES 
  (@DemoUserId, @CheckingId, @SalaryId, 'Income', 5000.00, 'Monthly Salary', 'Monthly', '2024-01-01', DATEADD(MONTH, 1, @CurrentMonth)),
  (@DemoUserId, @CheckingId, @HousingId, 'Expense', 1500.00, 'Rent Payment', 'Monthly', '2024-01-01', DATEADD(MONTH, 1, @CurrentMonth)),
  (@DemoUserId, @CreditId, @EntertainmentId, 'Expense', 15.99, 'Netflix Subscription', 'Monthly', '2024-01-15', DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 15)));

-- Insert savings goals
INSERT INTO Goals (UserId, Name, TargetAmount, CurrentAmount, TargetDate, Description)
VALUES 
  (@DemoUserId, 'Emergency Fund', 10000.00, 5000.00, DATEADD(YEAR, 1, @Today), 'Build 6 months of expenses as emergency fund'),
  (@DemoUserId, 'Vacation Fund', 3000.00, 1200.00, DATEADD(MONTH, 6, @Today), 'Summer vacation to Europe'),
  (@DemoUserId, 'New Laptop', 2000.00, 800.00, DATEADD(MONTH, 4, @Today), 'Save for new work laptop');

PRINT 'Seed data inserted successfully';
