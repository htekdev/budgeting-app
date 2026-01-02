using BudgetBuddy.Domain.Common;

namespace BudgetBuddy.Domain.Entities;

public class Budget : BaseEntity
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public required Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public ICollection<Category> Categories { get; set; } = new List<Category>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
