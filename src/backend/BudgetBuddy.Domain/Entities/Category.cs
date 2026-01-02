using BudgetBuddy.Domain.Common;

namespace BudgetBuddy.Domain.Entities;

public class Category : BaseEntity
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public required string Color { get; set; } = "#000000";
    public required string Icon { get; set; } = "default";
    public decimal AllocatedAmount { get; set; }
    public required Guid BudgetId { get; set; }
    public Budget Budget { get; set; } = null!;
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
