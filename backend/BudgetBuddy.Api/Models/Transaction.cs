namespace BudgetBuddy.Api.Models;

public class Transaction
{
    public int Id { get; set; }
    public required string Description { get; set; }
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public TransactionType Type { get; set; }
    public int BudgetId { get; set; }
    public Budget? Budget { get; set; }
    public int? CategoryId { get; set; }
    public Category? Category { get; set; }
    public DateTime CreatedAt { get; set; }
}

public enum TransactionType
{
    Income,
    Expense
}
