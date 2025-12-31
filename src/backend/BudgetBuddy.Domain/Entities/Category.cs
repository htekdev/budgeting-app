namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class Category : BaseEntity
{
    public int CategoryId { get; set; }
    public int UserId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string CategoryType { get; set; } = string.Empty; // Income, Expense
    public int? ParentCategoryId { get; set; }
    public string? Icon { get; set; }
    public string? Color { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public User User { get; set; } = null!;
    public Category? ParentCategory { get; set; }
    public ICollection<Category> SubCategories { get; set; } = new List<Category>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
}
