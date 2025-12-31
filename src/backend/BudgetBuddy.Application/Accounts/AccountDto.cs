namespace BudgetBuddy.Application.Accounts;

public record AccountDto
{
    public int AccountId { get; init; }
    public string AccountName { get; init; } = string.Empty;
    public string AccountType { get; init; } = string.Empty;
    public decimal CurrentBalance { get; init; }
    public string Currency { get; init; } = "USD";
    public bool IsActive { get; init; }
}

public record CreateAccountRequest
{
    public int UserId { get; init; }
    public string AccountName { get; init; } = string.Empty;
    public string AccountType { get; init; } = string.Empty;
    public decimal InitialBalance { get; init; }
    public string Currency { get; init; } = "USD";
}
