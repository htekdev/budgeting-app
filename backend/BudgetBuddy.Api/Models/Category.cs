namespace BudgetBuddy.Api.Models;

public class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public decimal AllocatedAmount { get; set; }
    public required string Color { get; set; }
    public int BudgetId { get; set; }
    public Budget? Budget { get; set; }
    
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
