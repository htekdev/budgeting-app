---
name: budget-calculation
description: Provides step-by-step guidance for implementing budget calculation logic including remaining budget, overspending detection, and budget period rollover
license: MIT
---

# Budget Calculation Skill

This skill helps implement correct budget calculation logic for the BudgetBuddy application.

## Core Concepts

### Budget Structure
A budget consists of:
- **Amount**: The allocated budget amount for a period
- **Period**: Time period (monthly, yearly)
- **Category**: The expense category it applies to
- **Start Date**: When the budget period begins

### Calculation Rules

#### 1. Remaining Budget
```
Remaining Budget = Budget Amount - Total Spent in Period
```

Where:
- Total Spent = Sum of all transactions in the category during the budget period
- Include only expense transactions (not income)
- Filter by date range based on budget period

#### 2. Budget Status
```
If Remaining Budget >= 0: "On Track"
If Remaining Budget < 0 and >= -0.1 * Budget Amount: "Warning"
If Remaining Budget < -0.1 * Budget Amount: "Overspent"
```

#### 3. Percentage Used
```
Percentage Used = (Total Spent / Budget Amount) * 100
```

#### 4. Period Rollover
- When a budget period ends, the budget resets
- Previous period's remaining amount does NOT carry over
- Historical data is preserved for reporting

## Implementation Guide

### Backend (C#)

```csharp
public class BudgetCalculationService
{
    public decimal CalculateRemainingBudget(Budget budget, IEnumerable<Transaction> transactions)
    {
        var periodStart = GetPeriodStart(budget);
        var periodEnd = GetPeriodEnd(budget);
        
        var totalSpent = transactions
            .Where(t => t.CategoryId == budget.CategoryId)
            .Where(t => t.Date >= periodStart && t.Date <= periodEnd)
            .Where(t => t.Type == TransactionType.Expense)
            .Sum(t => t.Amount);
        
        return budget.Amount - totalSpent;
    }
    
    public BudgetStatus GetBudgetStatus(decimal remaining, decimal budgetAmount)
    {
        if (remaining >= 0)
            return BudgetStatus.OnTrack;
        
        if (remaining >= -0.1m * budgetAmount)
            return BudgetStatus.Warning;
        
        return BudgetStatus.Overspent;
    }
}
```

### Frontend (TypeScript)

```typescript
interface BudgetCalculation {
  remaining: number;
  spent: number;
  percentageUsed: number;
  status: 'OnTrack' | 'Warning' | 'Overspent';
}

function calculateBudget(
  budget: Budget,
  transactions: Transaction[]
): BudgetCalculation {
  const periodTransactions = transactions.filter(
    t => t.categoryId === budget.categoryId &&
         t.date >= budget.periodStart &&
         t.date <= budget.periodEnd &&
         t.type === 'expense'
  );
  
  const spent = periodTransactions.reduce((sum, t) => sum + t.amount, 0);
  const remaining = budget.amount - spent;
  const percentageUsed = (spent / budget.amount) * 100;
  
  let status: 'OnTrack' | 'Warning' | 'Overspent' = 'OnTrack';
  if (remaining < 0) {
    status = remaining >= -0.1 * budget.amount ? 'Warning' : 'Overspent';
  }
  
  return { remaining, spent, percentageUsed, status };
}
```

## Common Pitfalls to Avoid

1. **Don't include income transactions** in budget calculations
2. **Always filter by date range** - don't mix periods
3. **Handle null/empty transaction lists** gracefully
4. **Use decimal for currency** in .NET (never float/double)
5. **Round percentages appropriately** for display
6. **Consider timezone** when comparing dates

## Testing Scenarios

### Test Case 1: Budget On Track
- Budget Amount: $1000
- Spent: $600
- Expected: Remaining = $400, Status = "On Track"

### Test Case 2: Budget Warning
- Budget Amount: $1000
- Spent: $1050
- Expected: Remaining = -$50, Status = "Warning"

### Test Case 3: Budget Overspent
- Budget Amount: $1000
- Spent: $1200
- Expected: Remaining = -$200, Status = "Overspent"

### Test Case 4: No Transactions
- Budget Amount: $1000
- Spent: $0
- Expected: Remaining = $1000, Status = "On Track"

### Test Case 5: Period Boundary
- Budget Period: Jan 1-31
- Transaction Date: Jan 31 23:59:59 (should include)
- Transaction Date: Feb 1 00:00:00 (should exclude)

## Performance Considerations

1. **Cache calculations** when displaying multiple budgets
2. **Index database** on CategoryId and Date columns
3. **Aggregate in database** when possible (don't pull all transactions)
4. **Use materialized views** for frequently accessed calculations

## Edge Cases

1. Zero budget amount (division by zero)
2. Negative budget amounts (validation error)
3. Future-dated budgets (no spending yet)
4. Overlapping budget periods
5. Budget period spans DST change
