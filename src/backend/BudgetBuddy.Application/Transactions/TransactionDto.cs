namespace BudgetBuddy.Application.Transactions;

public record TransactionDto
{
    public int TransactionId { get; init; }
    public int AccountId { get; init; }
    public string AccountName { get; init; } = string.Empty;
    public int? CategoryId { get; init; }
    public string? CategoryName { get; init; }
    public string TransactionType { get; init; } = string.Empty;
    public decimal Amount { get; init; }
    public DateTime TransactionDate { get; init; }
    public string? Description { get; init; }
    public string? Notes { get; init; }
}

public record CreateTransactionRequest
{
    public int UserId { get; init; }
    public int AccountId { get; init; }
    public int? CategoryId { get; init; }
    public string TransactionType { get; init; } = string.Empty;
    public decimal Amount { get; init; }
    public DateTime TransactionDate { get; init; }
    public string? Description { get; init; }
    public string? Notes { get; init; }
    public int? ToAccountId { get; init; }
}
