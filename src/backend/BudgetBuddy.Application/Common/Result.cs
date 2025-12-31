namespace BudgetBuddy.Application.Common;

public record Result<T>
{
    public bool IsSuccess { get; init; }
    public T? Data { get; init; }
    public string? Error { get; init; }

    public static Result<T> Success(T data) => new() { IsSuccess = true, Data = data };
    public static Result<T> Failure(string error) => new() { IsSuccess = false, Error = error };
}

public record Result
{
    public bool IsSuccess { get; init; }
    public string? Error { get; init; }

    public static Result Success() => new() { IsSuccess = true };
    public static Result Failure(string error) => new() { IsSuccess = false, Error = error };
}
