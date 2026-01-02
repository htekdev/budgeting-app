using BudgetBuddy.Domain.Common;

namespace BudgetBuddy.Domain.Entities;

public class Transaction : BaseEntity
{
    public required string Description { get; set; }
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public required TransactionType Type { get; set; }
    public string? Notes { get; set; }
    public required Guid BudgetId { get; set; }
    public Budget Budget { get; set; } = null!;
    public Guid? CategoryId { get; set; }
    public Category? Category { get; set; }
}

public enum TransactionType
{
    Income,
    Expense
}
