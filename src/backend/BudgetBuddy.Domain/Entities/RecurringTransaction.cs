namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class RecurringTransaction : BaseEntity
{
    public int RecurringTransactionId { get; set; }
    public int UserId { get; set; }
    public int AccountId { get; set; }
    public int? CategoryId { get; set; }
    public string TransactionType { get; set; } = string.Empty; // Income, Expense
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Frequency { get; set; } = string.Empty; // Daily, Weekly, Biweekly, Monthly, Quarterly, Yearly
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public DateTime? LastGeneratedDate { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public User User { get; set; } = null!;
    public Account Account { get; set; } = null!;
    public Category? Category { get; set; }
    public ICollection<Transaction> GeneratedTransactions { get; set; } = new List<Transaction>();
}
