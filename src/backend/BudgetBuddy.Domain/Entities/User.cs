using BudgetBuddy.Domain.Common;

namespace BudgetBuddy.Domain.Entities;

public class User : BaseEntity
{
    public required string Email { get; set; }
    public required string DisplayName { get; set; }
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
}
