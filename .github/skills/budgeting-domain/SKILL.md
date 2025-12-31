---
name: budgeting-domain
description: Domain rules and business logic for budgeting application
---

# Budgeting Domain Skill

## Overview

This skill provides guidance on implementing business rules for the budgeting domain including budgets, recurring transactions, goals, and cashflow calculations.

## Core Concepts

### 1. Accounts
Financial accounts that hold money and track balances.

**Types**:
- **Checking**: Day-to-day spending account
- **Savings**: Interest-bearing savings
- **Credit**: Credit card (negative balance allowed)
- **Investment**: Investment accounts

**Rules**:
- Each account has a current balance
- Balance is updated when transactions are created
- Credit accounts can have negative balances
- Other account types should not go negative (enforce in validation)

### 2. Transactions
Records of money movement.

**Types**:
- **Income**: Money coming in (increases account balance)
- **Expense**: Money going out (decreases account balance)
- **Transfer**: Money moving between accounts

**Rules**:
- All transactions must have a positive amount
- Income transactions increase account balance
- Expense transactions decrease account balance
- Transfers move money from one account to another (atomic operation)
- Transactions are immutable once created (create new transaction to correct)

**Implementation**:
```csharp
public async Task<Transaction> CreateTransactionAsync(
    int userId,
    CreateTransactionRequest request)
{
    var transaction = new Transaction
    {
        UserId = userId,
        AccountId = request.AccountId,
        CategoryId = request.CategoryId,
        TransactionType = request.TransactionType,
        Amount = request.Amount,
        TransactionDate = request.TransactionDate,
        Description = request.Description
    };

    // Update account balance
    var account = await _context.Accounts.FindAsync(request.AccountId);
    if (account == null) throw new NotFoundException("Account not found");

    if (request.TransactionType == "Income")
    {
        account.CurrentBalance += request.Amount;
    }
    else if (request.TransactionType == "Expense")
    {
        account.CurrentBalance -= request.Amount;
        
        // Enforce non-negative balance for non-credit accounts
        if (account.AccountType != "Credit" && account.CurrentBalance < 0)
        {
            throw new ValidationException("Insufficient funds");
        }
    }
    else if (request.TransactionType == "Transfer")
    {
        // Validate ToAccountId is provided
        if (!request.ToAccountId.HasValue)
        {
            throw new ValidationException("ToAccountId required for transfers");
        }

        var toAccount = await _context.Accounts.FindAsync(request.ToAccountId.Value);
        if (toAccount == null) throw new NotFoundException("Destination account not found");

        // Deduct from source account
        account.CurrentBalance -= request.Amount;
        if (account.AccountType != "Credit" && account.CurrentBalance < 0)
        {
            throw new ValidationException("Insufficient funds");
        }

        // Add to destination account
        toAccount.CurrentBalance += request.Amount;
    }

    _context.Transactions.Add(transaction);
    await _context.SaveChangesAsync();

    return transaction;
}
```

### 3. Budgets
Monthly spending limits per category.

**Rules**:
- Budgets are set per category per month
- Only expense categories can have budgets
- Budget amounts must be positive
- One budget per category per month (unique constraint)
- Budget variance = Budget Amount - Actual Spent

**Calculating Budget vs Actual**:
```csharp
public async Task<BudgetSummary> GetBudgetSummaryAsync(
    int userId,
    DateTime month)
{
    var firstDayOfMonth = new DateTime(month.Year, month.Month, 1);
    var firstDayOfNextMonth = firstDayOfMonth.AddMonths(1);

    var budgets = await _context.Budgets
        .Where(b => b.UserId == userId && b.BudgetMonth == firstDayOfMonth)
        .Include(b => b.Category)
        .ToListAsync();

    var summary = new List<BudgetItem>();

    foreach (var budget in budgets)
    {
        var actualSpent = await _context.Transactions
            .Where(t => 
                t.UserId == userId &&
                t.CategoryId == budget.CategoryId &&
                t.TransactionType == "Expense" &&
                t.TransactionDate >= firstDayOfMonth &&
                t.TransactionDate < firstDayOfNextMonth)
            .SumAsync(t => t.Amount);

        summary.Add(new BudgetItem
        {
            CategoryId = budget.CategoryId,
            CategoryName = budget.Category.CategoryName,
            BudgetAmount = budget.BudgetAmount,
            ActualAmount = actualSpent,
            Variance = budget.BudgetAmount - actualSpent,
            PercentUsed = budget.BudgetAmount > 0 
                ? (actualSpent / budget.BudgetAmount) * 100 
                : 0
        });
    }

    return new BudgetSummary
    {
        Month = firstDayOfMonth,
        Items = summary,
        TotalBudgeted = summary.Sum(i => i.BudgetAmount),
        TotalSpent = summary.Sum(i => i.ActualAmount),
        OverallVariance = summary.Sum(i => i.Variance)
    };
}
```

### 4. Recurring Transactions
Scheduled regular transactions (salary, rent, subscriptions).

**Frequencies**:
- Daily
- Weekly (every 7 days)
- Biweekly (every 14 days)
- Monthly (same day each month)
- Quarterly (every 3 months)
- Yearly (same date each year)

**Rules**:
- StartDate is required
- EndDate is optional (ongoing if null)
- LastGeneratedDate tracks when we last created transactions
- IsActive controls whether to generate new transactions
- Generated transactions link back to recurring transaction

**Generating Future Transactions**:
```csharp
public async Task<List<Transaction>> GenerateRecurringTransactionsAsync(
    int recurringTransactionId,
    DateTime untilDate)
{
    var recurring = await _context.RecurringTransactions
        .Include(r => r.Account)
        .FirstOrDefaultAsync(r => r.RecurringTransactionId == recurringTransactionId);

    if (recurring == null || !recurring.IsActive)
    {
        return new List<Transaction>();
    }

    var generatedTransactions = new List<Transaction>();
    var currentDate = recurring.LastGeneratedDate ?? recurring.StartDate;

    while (currentDate <= untilDate)
    {
        // Don't generate if past end date
        if (recurring.EndDate.HasValue && currentDate > recurring.EndDate.Value)
        {
            break;
        }

        var transaction = new Transaction
        {
            UserId = recurring.UserId,
            AccountId = recurring.AccountId,
            CategoryId = recurring.CategoryId,
            TransactionType = recurring.TransactionType,
            Amount = recurring.Amount,
            TransactionDate = currentDate,
            Description = recurring.Description,
            RecurringTransactionId = recurring.RecurringTransactionId
        };

        _context.Transactions.Add(transaction);
        generatedTransactions.Add(transaction);

        // Calculate next date based on frequency
        currentDate = CalculateNextDate(currentDate, recurring.Frequency);
    }

    // Update last generated date
    if (generatedTransactions.Any())
    {
        recurring.LastGeneratedDate = generatedTransactions.Max(t => t.TransactionDate);
    }

    await _context.SaveChangesAsync();

    return generatedTransactions;
}

private DateTime CalculateNextDate(DateTime currentDate, string frequency)
{
    return frequency switch
    {
        "Daily" => currentDate.AddDays(1),
        "Weekly" => currentDate.AddDays(7),
        "Biweekly" => currentDate.AddDays(14),
        "Monthly" => currentDate.AddMonths(1),
        "Quarterly" => currentDate.AddMonths(3),
        "Yearly" => currentDate.AddYears(1),
        _ => throw new ArgumentException($"Unknown frequency: {frequency}")
    };
}
```

### 5. Goals
Savings goals with target amounts and dates.

**Rules**:
- Target amount must be positive
- Current amount starts at 0 and increases with contributions
- Target date is optional
- Can link to a specific account
- Goals can be completed (IsCompleted = true)
- When current amount >= target amount, auto-mark as completed

**Contributing to Goal**:
```csharp
public async Task<Goal> ContributeToGoalAsync(
    int goalId,
    decimal amount,
    int fromAccountId)
{
    var goal = await _context.Goals
        .Include(g => g.Account)
        .FirstOrDefaultAsync(g => g.GoalId == goalId);

    if (goal == null) throw new NotFoundException("Goal not found");
    if (goal.IsCompleted) throw new ValidationException("Goal already completed");
    if (amount <= 0) throw new ValidationException("Contribution must be positive");

    // Create a transaction for the contribution
    var transaction = new Transaction
    {
        UserId = goal.UserId,
        AccountId = fromAccountId,
        TransactionType = "Expense",
        Amount = amount,
        TransactionDate = DateTime.Today,
        Description = $"Contribution to goal: {goal.GoalName}",
        Notes = $"Goal ID: {goalId}"
    };

    _context.Transactions.Add(transaction);

    // Update goal progress
    goal.CurrentAmount += amount;

    // Check if goal is completed
    if (goal.CurrentAmount >= goal.TargetAmount)
    {
        goal.IsCompleted = true;
        goal.CompletedAt = DateTime.UtcNow;
    }

    await _context.SaveChangesAsync();

    return goal;
}
```

## Common Pitfalls

1. **Forgetting to update account balances** when creating transactions
2. **Not handling transfer transactions** atomically (both accounts must update)
3. **Allowing negative balances** on non-credit accounts
4. **Not validating date ranges** for recurring transaction generation
5. **Generating duplicate recurring transactions** (check LastGeneratedDate)
6. **Not considering timezone issues** when working with dates
7. **Forgetting to mark goals as completed** when target reached

## Testing Considerations

Always test:
- Budget variance calculations with various scenarios
- Recurring transaction generation across month boundaries
- Transfer transactions (atomic updates to both accounts)
- Goal completion logic
- Account balance updates
- Edge cases (zero amounts, missing categories, etc.)

## Example Test Cases

```csharp
[Fact]
public void CalculateBudgetVariance_WhenUnderBudget_ReturnsPositive()
{
    var budgetAmount = 1000m;
    var actualSpent = 800m;
    var variance = budgetAmount - actualSpent;
    Assert.Equal(200m, variance);
}

[Fact]
public void CalculateBudgetVariance_WhenOverBudget_ReturnsNegative()
{
    var budgetAmount = 1000m;
    var actualSpent = 1200m;
    var variance = budgetAmount - actualSpent;
    Assert.Equal(-200m, variance);
}

[Fact]
public async Task GenerateRecurringTransactions_Monthly_SkipsWeekends()
{
    // If recurring is set for 31st but month has 30 days,
    // should use last day of month
}
```
