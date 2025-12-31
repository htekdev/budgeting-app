---
name: Budgeting Domain
description: Domain-specific business logic and rules for budgeting applications
---

# Budgeting Domain Skill

## Overview

This skill provides domain-specific knowledge about budgeting applications, including business rules, calculations, and common patterns.

## Core Concepts

### 1. Accounts

Represents where money is held or owed.

**Types**:
- **Checking**: Day-to-day spending account
- **Savings**: Money set aside for future use
- **Credit**: Money owed (negative balance)
- **Investment**: Long-term growth accounts
- **Cash**: Physical currency

**Key Rules**:
- Each account has a balance
- Balance can be positive (asset) or negative (liability)
- Credit accounts typically have negative balances
- Transactions affect account balances

### 2. Transactions

Record of money movement.

**Types**:
- **Income**: Money coming in (+)
- **Expense**: Money going out (-)
- **Transfer**: Money moving between accounts (neutral to net worth)

**Key Rules**:
- Every transaction must have a date
- Transactions should be categorized (except transfers)
- Transfers require both source and destination accounts
- Transaction amounts are always positive; type determines impact

### 3. Categories

Classification for transactions.

**Types**:
- **Income Categories**: Salary, Freelance, Investment Income, etc.
- **Expense Categories**: Housing, Food, Transportation, etc.

**Key Rules**:
- Categories can have parent categories (hierarchical)
- Each category is either Income or Expense
- Transfers don't need categories
- Categories help with reporting and budgeting

### 4. Budgets

Planned spending/income for a period.

**Key Rules**:
- Budgets are per category per month
- Budget amount represents the planned amount
- Compare budget vs. actual to track performance
- Budget variance = Budget Amount - Actual Spent

**Calculations**:
```csharp
var variance = budget.Amount - actualSpent;
var percentUsed = (actualSpent / budget.Amount) * 100;
var remaining = budget.Amount - actualSpent;
```

### 5. Recurring Transactions

Predictable, repeating transactions.

**Frequencies**:
- Daily
- Weekly
- Bi-Weekly (every 2 weeks)
- Monthly
- Quarterly (every 3 months)
- Yearly

**Key Rules**:
- Track next occurrence date
- Generate actual transactions from templates
- Can have start and end dates
- Can be income or expense

**Next Occurrence Calculation**:
```csharp
DateTime CalculateNextOccurrence(DateTime current, RecurrenceFrequency frequency)
{
    return frequency switch
    {
        RecurrenceFrequency.Daily => current.AddDays(1),
        RecurrenceFrequency.Weekly => current.AddDays(7),
        RecurrenceFrequency.BiWeekly => current.AddDays(14),
        RecurrenceFrequency.Monthly => current.AddMonths(1),
        RecurrenceFrequency.Quarterly => current.AddMonths(3),
        RecurrenceFrequency.Yearly => current.AddYears(1),
        _ => throw new ArgumentException("Invalid frequency")
    };
}
```

### 6. Goals

Savings targets.

**Key Rules**:
- Have target amount and optional target date
- Track current progress
- Calculate percentage complete
- Mark as completed when target reached

**Calculations**:
```csharp
var progressPercent = (goal.CurrentAmount / goal.TargetAmount) * 100;
var remainingAmount = goal.TargetAmount - goal.CurrentAmount;
var isOnTrack = CalculateOnTrackStatus(goal);

bool CalculateOnTrackStatus(Goal goal)
{
    if (!goal.TargetDate.HasValue) return true;
    
    var timeElapsed = DateTime.UtcNow - goal.CreatedAt;
    var totalTime = goal.TargetDate.Value - goal.CreatedAt;
    var expectedProgress = goal.TargetAmount * (timeElapsed / totalTime);
    
    return goal.CurrentAmount >= expectedProgress;
}
```

## Common Business Rules

### Budget Alerts

```csharp
public enum BudgetStatus
{
    OnTrack,      // < 80% used
    Warning,      // 80-100% used
    OverBudget    // > 100% used
}

BudgetStatus GetBudgetStatus(decimal budgetAmount, decimal actualSpent)
{
    var percentUsed = (actualSpent / budgetAmount) * 100;
    
    if (percentUsed > 100) return BudgetStatus.OverBudget;
    if (percentUsed >= 80) return BudgetStatus.Warning;
    return BudgetStatus.OnTrack;
}
```

### Net Worth Calculation

```csharp
decimal CalculateNetWorth(IEnumerable<Account> accounts)
{
    return accounts
        .Where(a => a.IsActive)
        .Sum(a => a.Balance);
}
```

### Cash Flow Calculation

```csharp
public class CashFlowSummary
{
    public decimal TotalIncome { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetCashFlow => TotalIncome - TotalExpenses;
    public decimal SavingsRate => TotalIncome > 0 
        ? (NetCashFlow / TotalIncome) * 100 
        : 0;
}

async Task<CashFlowSummary> CalculateCashFlow(int userId, DateTime from, DateTime to)
{
    var transactions = await _context.Transactions
        .Where(t => t.UserId == userId 
                 && t.TransactionDate >= from 
                 && t.TransactionDate <= to
                 && t.Type != TransactionType.Transfer)
        .ToListAsync();

    return new CashFlowSummary
    {
        TotalIncome = transactions
            .Where(t => t.Type == TransactionType.Income)
            .Sum(t => t.Amount),
        TotalExpenses = transactions
            .Where(t => t.Type == TransactionType.Expense)
            .Sum(t => t.Amount)
    };
}
```

### Spend by Category Report

```csharp
public class CategorySpending
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public decimal TotalSpent { get; set; }
    public int TransactionCount { get; set; }
    public decimal PercentageOfTotal { get; set; }
}

async Task<IEnumerable<CategorySpending>> GetSpendByCategory(
    int userId, 
    DateTime month)
{
    var startOfMonth = new DateTime(month.Year, month.Month, 1);
    var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

    var categorySpending = await _context.Transactions
        .Where(t => t.UserId == userId
                 && t.Type == TransactionType.Expense
                 && t.TransactionDate >= startOfMonth
                 && t.TransactionDate <= endOfMonth
                 && t.CategoryId != null)
        .GroupBy(t => new { t.CategoryId, t.Category!.Name })
        .Select(g => new CategorySpending
        {
            CategoryId = g.Key.CategoryId!.Value,
            CategoryName = g.Key.Name,
            TotalSpent = g.Sum(t => t.Amount),
            TransactionCount = g.Count()
        })
        .ToListAsync();

    var totalSpent = categorySpending.Sum(c => c.TotalSpent);
    
    foreach (var category in categorySpending)
    {
        category.PercentageOfTotal = totalSpent > 0 
            ? (category.TotalSpent / totalSpent) * 100 
            : 0;
    }

    return categorySpending.OrderByDescending(c => c.TotalSpent);
}
```

## Transaction Handling

### Creating a Transfer

```csharp
async Task CreateTransfer(int userId, int fromAccountId, int toAccountId, decimal amount, string description)
{
    using var transaction = await _context.Database.BeginTransactionAsync();
    
    try
    {
        var fromAccount = await _context.Accounts.FindAsync(fromAccountId);
        var toAccount = await _context.Accounts.FindAsync(toAccountId);
        
        if (fromAccount == null || toAccount == null)
            throw new NotFoundException("Account not found");
        
        if (fromAccount.UserId != userId || toAccount.UserId != userId)
            throw new UnauthorizedException("Not authorized");

        // Create transfer transaction
        var transferTransaction = new Transaction
        {
            UserId = userId,
            AccountId = fromAccountId,
            ToAccountId = toAccountId,
            Type = TransactionType.Transfer,
            Amount = amount,
            Description = description,
            TransactionDate = DateTime.UtcNow
        };
        
        // Update balances
        fromAccount.Balance -= amount;
        toAccount.Balance += amount;
        
        _context.Transactions.Add(transferTransaction);
        await _context.SaveChangesAsync();
        await transaction.CommitAsync();
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

### Generating Recurring Transactions

```csharp
async Task<List<Transaction>> GenerateRecurringTransactions(int recurringTransactionId, DateTime until)
{
    var recurring = await _context.RecurringTransactions
        .FindAsync(recurringTransactionId);
    
    if (recurring == null || !recurring.IsActive)
        return new List<Transaction>();

    var generatedTransactions = new List<Transaction>();
    var currentDate = recurring.NextOccurrence;

    while (currentDate <= until && (recurring.EndDate == null || currentDate <= recurring.EndDate))
    {
        var transaction = new Transaction
        {
            UserId = recurring.UserId,
            AccountId = recurring.AccountId,
            CategoryId = recurring.CategoryId,
            Type = recurring.Type,
            Amount = recurring.Amount,
            Description = recurring.Description,
            TransactionDate = currentDate,
            ToAccountId = recurring.ToAccountId
        };

        generatedTransactions.Add(transaction);
        currentDate = CalculateNextOccurrence(currentDate, recurring.Frequency);
    }

    // Update next occurrence
    recurring.NextOccurrence = currentDate;

    _context.Transactions.AddRange(generatedTransactions);
    await _context.SaveChangesAsync();

    return generatedTransactions;
}
```

## Validation Rules

### Account Validation

- Name is required and max 200 characters
- Type is required and must be valid enum value
- Currency is required (default USD)
- Balance can be negative only for Credit accounts

### Transaction Validation

- Amount must be positive (type determines impact)
- Date is required and cannot be in future (configurable)
- Income/Expense must have category
- Transfer must have ToAccountId
- Transfer must have different source and destination

### Budget Validation

- Amount must be positive
- Month must be first day of month
- Cannot have duplicate budgets (same user, category, month)
- Category must be expense category (not income)

### Goal Validation

- Target amount must be positive
- Current amount cannot exceed target amount
- Target date (if provided) must be in future

## Common Queries

### Monthly Budget Summary

```csharp
var summary = await _context.Budgets
    .Where(b => b.UserId == userId && b.Month == month)
    .Include(b => b.Category)
    .Select(b => new
    {
        b.CategoryId,
        b.Category.Name,
        BudgetAmount = b.Amount,
        ActualSpent = _context.Transactions
            .Where(t => t.UserId == userId
                     && t.CategoryId == b.CategoryId
                     && t.Type == TransactionType.Expense
                     && t.TransactionDate >= month
                     && t.TransactionDate < month.AddMonths(1))
            .Sum(t => (decimal?)t.Amount) ?? 0
    })
    .ToListAsync();
```

### Account Balance History

```csharp
var history = await _context.Transactions
    .Where(t => t.AccountId == accountId)
    .OrderBy(t => t.TransactionDate)
    .Select(t => new
    {
        t.TransactionDate,
        t.Type,
        t.Amount,
        RunningBalance = /* calculate running balance */
    })
    .ToListAsync();
```

## Best Practices

1. **Always use transactions** for operations affecting multiple accounts
2. **Validate business rules** at the service layer, not just in UI
3. **Use decimal type** for money (never float or double)
4. **Store dates in UTC**, display in user's timezone
5. **Soft delete** instead of hard delete (set IsActive = false)
6. **Audit important changes** (use AuditEvents table)
7. **Calculate values**, don't store them (e.g., budget variance)
8. **Index date columns** for performance on reports

## Testing Domain Logic

```csharp
public class BudgetCalculationTests
{
    [Theory]
    [InlineData(1000, 800, 200)]       // Under budget
    [InlineData(1000, 1000, 0)]        // At budget
    [InlineData(1000, 1200, -200)]     // Over budget
    public void CalculateVariance_ReturnsCorrectValue(
        decimal budget, 
        decimal actual, 
        decimal expectedVariance)
    {
        // Act
        var variance = budget - actual;

        // Assert
        Assert.Equal(expectedVariance, variance);
    }
}
```
