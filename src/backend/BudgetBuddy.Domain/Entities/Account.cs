namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class Account : BaseEntity
{
    public int AccountId { get; set; }
    public int UserId { get; set; }
    public string AccountName { get; set; } = string.Empty;
    public string AccountType { get; set; } = string.Empty; // Checking, Savings, Credit, Investment
    public decimal CurrentBalance { get; set; }
    public string Currency { get; set; } = "USD";
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public User User { get; set; } = null!;
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<RecurringTransaction> RecurringTransactions { get; set; } = new List<RecurringTransaction>();
}
