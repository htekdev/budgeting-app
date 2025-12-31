namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class User : BaseEntity
{
    public int UserId { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<Account> Accounts { get; set; } = new List<Account>();
    public ICollection<Category> Categories { get; set; } = new List<Category>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
    public ICollection<Goal> Goals { get; set; } = new List<Goal>();
}
