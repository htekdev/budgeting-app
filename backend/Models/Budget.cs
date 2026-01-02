namespace BudgetBuddy.Api.Models;

public class Budget
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public int CategoryId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string Period { get; set; } = "monthly"; // monthly, yearly
    public int UserId { get; set; }
    
    // Navigation properties
    public Category? Category { get; set; }
    public User? User { get; set; }
}
