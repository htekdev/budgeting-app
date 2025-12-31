-- Seed Data for BudgetBuddy
-- Default user, categories, accounts, and sample transactions for local development

-- Insert default user
INSERT INTO Users (Email, FirstName, LastName, CreatedAt, UpdatedAt, IsActive)
VALUES ('demo@budgetbuddy.local', 'Demo', 'User', GETUTCDATE(), GETUTCDATE(), 1);

DECLARE @UserId INT = SCOPE_IDENTITY();

-- Insert default expense categories
INSERT INTO Categories (UserId, CategoryName, CategoryType, Icon, Color, IsActive, CreatedAt, UpdatedAt)
VALUES
    (@UserId, 'Housing', 'Expense', '🏠', '#FF6B6B', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Transportation', 'Expense', '🚗', '#4ECDC4', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Food & Dining', 'Expense', '🍔', '#45B7D1', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Groceries', 'Expense', '🛒', '#96CEB4', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Utilities', 'Expense', '⚡', '#FFEAA7', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Entertainment', 'Expense', '🎬', '#DFE6E9', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Healthcare', 'Expense', '🏥', '#74B9FF', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Shopping', 'Expense', '🛍️', '#A29BFE', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Personal Care', 'Expense', '💅', '#FD79A8', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Education', 'Expense', '📚', '#FDCB6E', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Insurance', 'Expense', '🛡️', '#6C5CE7', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Subscriptions', 'Expense', '📱', '#00B894', 1, GETUTCDATE(), GETUTCDATE());

-- Insert default income categories
INSERT INTO Categories (UserId, CategoryName, CategoryType, Icon, Color, IsActive, CreatedAt, UpdatedAt)
VALUES
    (@UserId, 'Salary', 'Income', '💰', '#00B894', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Freelance', 'Income', '💼', '#0984E3', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Investments', 'Income', '📈', '#6C5CE7', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Other Income', 'Income', '💵', '#FDCB6E', 1, GETUTCDATE(), GETUTCDATE());

-- Insert default accounts
INSERT INTO Accounts (UserId, AccountName, AccountType, CurrentBalance, Currency, IsActive, CreatedAt, UpdatedAt)
VALUES
    (@UserId, 'Checking Account', 'Checking', 5000.00, 'USD', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Savings Account', 'Savings', 15000.00, 'USD', 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Credit Card', 'Credit', -1200.00, 'USD', 1, GETUTCDATE(), GETUTCDATE());

DECLARE @CheckingAccountId INT = (SELECT AccountId FROM Accounts WHERE UserId = @UserId AND AccountName = 'Checking Account');
DECLARE @SavingsAccountId INT = (SELECT AccountId FROM Accounts WHERE UserId = @UserId AND AccountName = 'Savings Account');
DECLARE @CreditCardId INT = (SELECT AccountId FROM Accounts WHERE UserId = @UserId AND AccountName = 'Credit Card');

DECLARE @SalaryCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Salary');
DECLARE @HousingCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Housing');
DECLARE @GroceriesCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Groceries');
DECLARE @FoodDiningCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Food & Dining');
DECLARE @TransportationCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Transportation');
DECLARE @UtilitiesCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Utilities');
DECLARE @EntertainmentCategoryId INT = (SELECT CategoryId FROM Categories WHERE UserId = @UserId AND CategoryName = 'Entertainment');

-- Insert sample transactions (last 3 months)
DECLARE @CurrentDate DATE = CAST(GETUTCDATE() AS DATE);
DECLARE @ThreeMonthsAgo DATE = DATEADD(MONTH, -3, @CurrentDate);

-- Monthly salary (income)
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CheckingAccountId, @SalaryCategoryId, 'Income', 5000.00, DATEADD(MONTH, -3, @CurrentDate), 'Monthly Salary', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @SalaryCategoryId, 'Income', 5000.00, DATEADD(MONTH, -2, @CurrentDate), 'Monthly Salary', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @SalaryCategoryId, 'Income', 5000.00, DATEADD(MONTH, -1, @CurrentDate), 'Monthly Salary', GETUTCDATE(), GETUTCDATE());

-- Housing expenses
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CheckingAccountId, @HousingCategoryId, 'Expense', 1500.00, DATEADD(DAY, -90, @CurrentDate), 'Rent Payment', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @HousingCategoryId, 'Expense', 1500.00, DATEADD(DAY, -60, @CurrentDate), 'Rent Payment', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @HousingCategoryId, 'Expense', 1500.00, DATEADD(DAY, -30, @CurrentDate), 'Rent Payment', GETUTCDATE(), GETUTCDATE());

-- Groceries
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 150.00, DATEADD(DAY, -85, @CurrentDate), 'Whole Foods', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 200.00, DATEADD(DAY, -78, @CurrentDate), 'Trader Joes', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 175.00, DATEADD(DAY, -55, @CurrentDate), 'Whole Foods', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 180.00, DATEADD(DAY, -48, @CurrentDate), 'Safeway', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 165.00, DATEADD(DAY, -25, @CurrentDate), 'Whole Foods', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @GroceriesCategoryId, 'Expense', 190.00, DATEADD(DAY, -18, @CurrentDate), 'Costco', GETUTCDATE(), GETUTCDATE());

-- Food & Dining
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 45.00, DATEADD(DAY, -82, @CurrentDate), 'Restaurant Dinner', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 12.50, DATEADD(DAY, -75, @CurrentDate), 'Coffee Shop', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 35.00, DATEADD(DAY, -52, @CurrentDate), 'Lunch', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 60.00, DATEADD(DAY, -45, @CurrentDate), 'Date Night', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 28.00, DATEADD(DAY, -22, @CurrentDate), 'Fast Food', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @FoodDiningCategoryId, 'Expense', 50.00, DATEADD(DAY, -15, @CurrentDate), 'Restaurant', GETUTCDATE(), GETUTCDATE());

-- Transportation
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CheckingAccountId, @TransportationCategoryId, 'Expense', 50.00, DATEADD(DAY, -80, @CurrentDate), 'Gas', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @TransportationCategoryId, 'Expense', 55.00, DATEADD(DAY, -65, @CurrentDate), 'Gas', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @TransportationCategoryId, 'Expense', 45.00, DATEADD(DAY, -50, @CurrentDate), 'Gas', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @TransportationCategoryId, 'Expense', 52.00, DATEADD(DAY, -35, @CurrentDate), 'Gas', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @TransportationCategoryId, 'Expense', 48.00, DATEADD(DAY, -20, @CurrentDate), 'Gas', GETUTCDATE(), GETUTCDATE());

-- Utilities
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CheckingAccountId, @UtilitiesCategoryId, 'Expense', 120.00, DATEADD(DAY, -88, @CurrentDate), 'Electric Bill', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @UtilitiesCategoryId, 'Expense', 125.00, DATEADD(DAY, -58, @CurrentDate), 'Electric Bill', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @UtilitiesCategoryId, 'Expense', 118.00, DATEADD(DAY, -28, @CurrentDate), 'Electric Bill', GETUTCDATE(), GETUTCDATE());

-- Entertainment
INSERT INTO Transactions (UserId, AccountId, CategoryId, TransactionType, Amount, TransactionDate, Description, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CreditCardId, @EntertainmentCategoryId, 'Expense', 25.00, DATEADD(DAY, -70, @CurrentDate), 'Movie Tickets', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @EntertainmentCategoryId, 'Expense', 40.00, DATEADD(DAY, -42, @CurrentDate), 'Concert', GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CreditCardId, @EntertainmentCategoryId, 'Expense', 15.99, DATEADD(DAY, -30, @CurrentDate), 'Streaming Service', GETUTCDATE(), GETUTCDATE());

-- Insert sample recurring transactions
INSERT INTO RecurringTransactions (UserId, AccountId, CategoryId, TransactionType, Amount, Description, Frequency, StartDate, IsActive, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @CheckingAccountId, @SalaryCategoryId, 'Income', 5000.00, 'Monthly Salary', 'Monthly', DATEADD(MONTH, -6, @CurrentDate), 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @HousingCategoryId, 'Expense', 1500.00, 'Rent Payment', 'Monthly', DATEADD(MONTH, -6, @CurrentDate), 1, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @CheckingAccountId, @UtilitiesCategoryId, 'Expense', 120.00, 'Electric Bill', 'Monthly', DATEADD(MONTH, -6, @CurrentDate), 1, GETUTCDATE(), GETUTCDATE());

-- Insert sample budgets for current month
DECLARE @CurrentMonth DATE = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);

INSERT INTO Budgets (UserId, CategoryId, BudgetMonth, BudgetAmount, CreatedAt, UpdatedAt)
VALUES
    (@UserId, @HousingCategoryId, @CurrentMonth, 1500.00, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @GroceriesCategoryId, @CurrentMonth, 600.00, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @FoodDiningCategoryId, @CurrentMonth, 300.00, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @TransportationCategoryId, @CurrentMonth, 200.00, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @UtilitiesCategoryId, @CurrentMonth, 150.00, GETUTCDATE(), GETUTCDATE()),
    (@UserId, @EntertainmentCategoryId, @CurrentMonth, 200.00, GETUTCDATE(), GETUTCDATE());

-- Insert sample goal
INSERT INTO Goals (UserId, GoalName, TargetAmount, CurrentAmount, TargetDate, AccountId, IsCompleted, CreatedAt, UpdatedAt)
VALUES
    (@UserId, 'Emergency Fund', 10000.00, 5000.00, DATEADD(YEAR, 1, @CurrentDate), @SavingsAccountId, 0, GETUTCDATE(), GETUTCDATE()),
    (@UserId, 'Vacation Fund', 3000.00, 1500.00, DATEADD(MONTH, 6, @CurrentDate), @SavingsAccountId, 0, GETUTCDATE(), GETUTCDATE());

GO
