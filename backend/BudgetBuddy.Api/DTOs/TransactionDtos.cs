namespace BudgetBuddy.Api.DTOs;

public record TransactionDto(
    int Id,
    string Description,
    decimal Amount,
    DateTime Date,
    string Type,
    int BudgetId,
    int? CategoryId,
    DateTime CreatedAt
);

public record CreateTransactionDto(
    string Description,
    decimal Amount,
    DateTime Date,
    string Type,
    int BudgetId,
    int? CategoryId
);

public record UpdateTransactionDto(
    string Description,
    decimal Amount,
    DateTime Date,
    string Type,
    int? CategoryId
);
