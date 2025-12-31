namespace BudgetBuddy.Application.Categories;

public record CategoryDto
{
    public int CategoryId { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public string CategoryType { get; init; } = string.Empty;
    public int? ParentCategoryId { get; init; }
    public string? Icon { get; init; }
    public string? Color { get; init; }
    public bool IsActive { get; init; }
}

public record CreateCategoryRequest
{
    public int UserId { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public string CategoryType { get; init; } = string.Empty;
    public int? ParentCategoryId { get; init; }
    public string? Icon { get; init; }
    public string? Color { get; init; }
}
