using BudgetBuddy.Domain.Enums;

namespace BudgetBuddy.Domain.Entities;

public class Transaction : BaseEntity
{
    public int UserId { get; set; }
    public int AccountId { get; set; }
    public int? CategoryId { get; set; }
    public TransactionType Type { get; set; }
    public decimal Amount { get; set; }
    public string? Description { get; set; }
    public DateTime TransactionDate { get; set; }
    public int? ToAccountId { get; set; } // For transfers
    public string? Notes { get; set; }

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Account Account { get; set; } = null!;
    public virtual Category? Category { get; set; }
    public virtual Account? ToAccount { get; set; }
}
