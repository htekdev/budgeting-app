namespace BudgetBuddy.Domain.Entities;

public class Budget : BaseEntity
{
    public int UserId { get; set; }
    public int CategoryId { get; set; }
    public DateTime Month { get; set; } // First day of the month
    public decimal Amount { get; set; }
    public string? Notes { get; set; }

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Category Category { get; set; } = null!;
}
