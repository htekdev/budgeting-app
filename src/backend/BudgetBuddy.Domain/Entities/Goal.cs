namespace BudgetBuddy.Domain.Entities;

public class Goal : BaseEntity
{
    public int UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public DateTime? TargetDate { get; set; }
    public string? Description { get; set; }
    public bool IsCompleted { get; set; }

    // Navigation properties
    public virtual User User { get; set; } = null!;
}
