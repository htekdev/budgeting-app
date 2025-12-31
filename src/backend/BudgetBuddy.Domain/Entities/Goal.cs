namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class Goal : BaseEntity
{
    public int GoalId { get; set; }
    public int UserId { get; set; }
    public string GoalName { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public DateTime? TargetDate { get; set; }
    public int? AccountId { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Account? Account { get; set; }
}
