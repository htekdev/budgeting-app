namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class Budget : BaseEntity
{
    public int BudgetId { get; set; }
    public int UserId { get; set; }
    public int CategoryId { get; set; }
    public DateTime BudgetMonth { get; set; } // First day of the month
    public decimal BudgetAmount { get; set; }
    public string? Notes { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Category Category { get; set; } = null!;
}
