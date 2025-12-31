namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class Transaction : BaseEntity
{
    public int TransactionId { get; set; }
    public int UserId { get; set; }
    public int AccountId { get; set; }
    public int? CategoryId { get; set; }
    public string TransactionType { get; set; } = string.Empty; // Income, Expense, Transfer
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Description { get; set; }
    public string? Notes { get; set; }
    public int? ToAccountId { get; set; }
    public int? RecurringTransactionId { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Account Account { get; set; } = null!;
    public Category? Category { get; set; }
    public Account? ToAccount { get; set; }
    public RecurringTransaction? RecurringTransaction { get; set; }
}
