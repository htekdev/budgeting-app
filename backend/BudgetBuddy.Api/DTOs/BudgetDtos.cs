namespace BudgetBuddy.Api.DTOs;

public record BudgetDto(
    int Id,
    string Name,
    decimal TotalAmount,
    DateTime StartDate,
    DateTime EndDate,
    string UserId,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record CreateBudgetDto(
    string Name,
    decimal TotalAmount,
    DateTime StartDate,
    DateTime EndDate,
    string UserId
);

public record UpdateBudgetDto(
    string Name,
    decimal TotalAmount,
    DateTime StartDate,
    DateTime EndDate
);
