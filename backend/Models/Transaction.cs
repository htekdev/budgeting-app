namespace BudgetBuddy.Api.Models;

public class Transaction
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Type { get; set; } = "expense"; // expense, income
    public int CategoryId { get; set; }
    public int UserId { get; set; }
    
    // Navigation properties
    public Category? Category { get; set; }
    public User? User { get; set; }
}
