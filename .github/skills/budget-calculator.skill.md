# Budget Calculator Skill

## Description
Calculates various budget-related metrics including remaining amount, spending by category, percentage progress, and forecasts.

## Purpose
Provides reusable calculation logic for budget analysis that can be used across different contexts (API endpoints, reports, analytics).

## Input Parameters
- **budget**: Budget object with TotalAmount, StartDate, EndDate
- **transactions**: List of Transaction objects associated with the budget
- **categories**: Optional list of Category objects for breakdown

## Output
Returns a BudgetSummary object with:
- **totalBudget**: Total budgeted amount
- **totalSpent**: Sum of all expense transactions
- **totalIncome**: Sum of all income transactions
- **remaining**: Budget amount remaining (totalBudget - totalSpent + totalIncome)
- **percentUsed**: Percentage of budget used
- **daysRemaining**: Days left in budget period
- **dailyAverage**: Average spending per day
- **projectedTotal**: Projected total spending at current rate
- **categoryBreakdown**: Spending breakdown by category
- **isOverBudget**: Boolean indicating if over budget

## Example Usage

### Backend (C#)
```csharp
public static class BudgetCalculator
{
    public static BudgetSummary Calculate(Budget budget, List<Transaction> transactions)
    {
        var totalSpent = transactions
            .Where(t => t.Type == TransactionType.Expense)
            .Sum(t => t.Amount);
        
        var totalIncome = transactions
            .Where(t => t.Type == TransactionType.Income)
            .Sum(t => t.Amount);
        
        var remaining = budget.TotalAmount - totalSpent + totalIncome;
        var percentUsed = budget.TotalAmount > 0 
            ? (totalSpent / budget.TotalAmount) * 100 
            : 0;
        
        var daysPassed = (DateTime.UtcNow - budget.StartDate).Days + 1;
        var daysRemaining = (budget.EndDate - DateTime.UtcNow).Days;
        var totalDays = (budget.EndDate - budget.StartDate).Days + 1;
        
        var dailyAverage = daysPassed > 0 ? totalSpent / daysPassed : 0;
        var projectedTotal = dailyAverage * totalDays;
        
        var categoryBreakdown = transactions
            .Where(t => t.Type == TransactionType.Expense && t.CategoryId != null)
            .GroupBy(t => t.CategoryId)
            .Select(g => new CategorySpending
            {
                CategoryId = g.Key.Value,
                CategoryName = g.First().Category?.Name ?? "Unknown",
                Amount = g.Sum(t => t.Amount),
                Percentage = totalSpent > 0 ? (g.Sum(t => t.Amount) / totalSpent) * 100 : 0
            })
            .ToList();
        
        return new BudgetSummary
        {
            TotalBudget = budget.TotalAmount,
            TotalSpent = totalSpent,
            TotalIncome = totalIncome,
            Remaining = remaining,
            PercentUsed = percentUsed,
            DaysRemaining = daysRemaining,
            DailyAverage = dailyAverage,
            ProjectedTotal = projectedTotal,
            CategoryBreakdown = categoryBreakdown,
            IsOverBudget = remaining < 0
        };
    }
}

// Usage in endpoint
app.MapGet("/api/budgets/{id:guid}/summary", async (Guid id, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets
        .Include(b => b.Transactions)
            .ThenInclude(t => t.Category)
        .FirstOrDefaultAsync(b => b.Id == id);
    
    if (budget is null) return Results.NotFound();
    
    var summary = BudgetCalculator.Calculate(budget, budget.Transactions.ToList());
    return Results.Ok(summary);
})
.WithName("GetBudgetSummary")
.WithTags("Budgets");
```

### Frontend (TypeScript)
```typescript
interface BudgetSummary {
  totalBudget: number;
  totalSpent: number;
  totalIncome: number;
  remaining: number;
  percentUsed: number;
  daysRemaining: number;
  dailyAverage: number;
  projectedTotal: number;
  categoryBreakdown: CategorySpending[];
  isOverBudget: boolean;
}

interface CategorySpending {
  categoryId: string;
  categoryName: string;
  amount: number;
  percentage: number;
}

export function calculateBudgetSummary(
  budget: Budget,
  transactions: Transaction[]
): BudgetSummary {
  const expenses = transactions.filter(t => t.type === 'Expense');
  const incomes = transactions.filter(t => t.type === 'Income');
  
  const totalSpent = expenses.reduce((sum, t) => sum + t.amount, 0);
  const totalIncome = incomes.reduce((sum, t) => sum + t.amount, 0);
  const remaining = budget.totalAmount - totalSpent + totalIncome;
  const percentUsed = budget.totalAmount > 0 
    ? (totalSpent / budget.totalAmount) * 100 
    : 0;
  
  const now = new Date();
  const startDate = new Date(budget.startDate);
  const endDate = new Date(budget.endDate);
  
  const daysPassed = Math.floor((now.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;
  const daysRemaining = Math.floor((endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  const totalDays = Math.floor((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;
  
  const dailyAverage = daysPassed > 0 ? totalSpent / daysPassed : 0;
  const projectedTotal = dailyAverage * totalDays;
  
  const categoryMap = new Map<string, { name: string; amount: number }>();
  expenses.forEach(t => {
    if (t.categoryId) {
      const existing = categoryMap.get(t.categoryId) || { name: t.category?.name || 'Unknown', amount: 0 };
      existing.amount += t.amount;
      categoryMap.set(t.categoryId, existing);
    }
  });
  
  const categoryBreakdown = Array.from(categoryMap.entries()).map(([id, data]) => ({
    categoryId: id,
    categoryName: data.name,
    amount: data.amount,
    percentage: totalSpent > 0 ? (data.amount / totalSpent) * 100 : 0,
  }));
  
  return {
    totalBudget: budget.totalAmount,
    totalSpent,
    totalIncome,
    remaining,
    percentUsed,
    daysRemaining,
    dailyAverage,
    projectedTotal,
    categoryBreakdown,
    isOverBudget: remaining < 0,
  };
}

// Usage in component
export function BudgetSummaryCard({ budget, transactions }: Props) {
  const summary = calculateBudgetSummary(budget, transactions);
  
  return (
    <div className="budget-summary">
      <div className="stat">
        <label>Remaining</label>
        <span className={summary.isOverBudget ? 'negative' : 'positive'}>
          ${summary.remaining.toFixed(2)}
        </span>
      </div>
      <div className="stat">
        <label>Used</label>
        <span>{summary.percentUsed.toFixed(1)}%</span>
      </div>
      <div className="stat">
        <label>Daily Average</label>
        <span>${summary.dailyAverage.toFixed(2)}</span>
      </div>
      {summary.projectedTotal > budget.totalAmount && (
        <div className="alert">
          On track to exceed budget by ${(summary.projectedTotal - budget.totalAmount).toFixed(2)}
        </div>
      )}
    </div>
  );
}
```

## When to Use This Skill
- Implementing budget summary endpoints
- Creating budget dashboard widgets
- Generating budget reports
- Building budget analytics features
- Calculating spending insights

## Related Operations
- Budget forecasting
- Spending pattern analysis
- Category comparison
- Monthly/yearly trends
- Budget alerts and notifications
