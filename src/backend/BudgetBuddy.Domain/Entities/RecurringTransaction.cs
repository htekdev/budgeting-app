using BudgetBuddy.Domain.Enums;

namespace BudgetBuddy.Domain.Entities;

public class RecurringTransaction : BaseEntity
{
    public int UserId { get; set; }
    public int AccountId { get; set; }
    public int? CategoryId { get; set; }
    public TransactionType Type { get; set; }
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
    public RecurrenceFrequency Frequency { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public DateTime NextOccurrence { get; set; }
    public int? ToAccountId { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Account Account { get; set; } = null!;
    public virtual Category? Category { get; set; }
    public virtual Account? ToAccount { get; set; }
}
