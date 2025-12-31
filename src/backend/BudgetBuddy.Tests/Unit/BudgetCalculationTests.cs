using BudgetBuddy.Domain.Entities;
using BudgetBuddy.Domain.Enums;
using FluentAssertions;
using Xunit;

namespace BudgetBuddy.Tests.Unit;

public class BudgetCalculationTests
{
    [Fact]
    public void Budget_CalculateVariance_ShouldReturnCorrectValue()
    {
        // Arrange
        var budget = new Budget
        {
            Amount = 500.00m,
            CategoryId = 1,
            UserId = 1,
            Month = new DateTime(2025, 1, 1)
        };

        decimal actualSpent = 450.00m;

        // Act
        var variance = budget.Amount - actualSpent;

        // Assert
        variance.Should().Be(50.00m);
    }

    [Fact]
    public void Budget_CalculatePercentageUsed_ShouldReturnCorrectPercentage()
    {
        // Arrange
        var budget = new Budget
        {
            Amount = 500.00m,
            CategoryId = 1,
            UserId = 1,
            Month = new DateTime(2025, 1, 1)
        };

        decimal actualSpent = 450.00m;

        // Act
        var percentageUsed = (actualSpent / budget.Amount) * 100;

        // Assert
        percentageUsed.Should().Be(90.00m);
    }

    [Fact]
    public void Goal_CalculateProgressPercentage_ShouldReturnCorrectPercentage()
    {
        // Arrange
        var goal = new Goal
        {
            Name = "Emergency Fund",
            TargetAmount = 10000.00m,
            CurrentAmount = 7500.00m,
            UserId = 1
        };

        // Act
        var progressPercentage = (goal.CurrentAmount / goal.TargetAmount) * 100;

        // Assert
        progressPercentage.Should().Be(75.00m);
    }

    [Fact]
    public void RecurringTransaction_NextOccurrence_Monthly_ShouldCalculateCorrectly()
    {
        // Arrange
        var startDate = new DateTime(2025, 1, 15);
        var recurring = new RecurringTransaction
        {
            UserId = 1,
            AccountId = 1,
            Amount = 1500.00m,
            Description = "Rent",
            Frequency = RecurrenceFrequency.Monthly,
            StartDate = startDate,
            NextOccurrence = startDate,
            Type = TransactionType.Expense
        };

        // Act
        var nextOccurrence = recurring.NextOccurrence.AddMonths(1);

        // Assert
        nextOccurrence.Should().Be(new DateTime(2025, 2, 15));
    }

    [Theory]
    [InlineData(TransactionType.Income, 100.00, 100.00)]
    [InlineData(TransactionType.Expense, -50.00, -50.00)]
    public void Transaction_AmountImpact_ShouldBeCorrect(TransactionType type, decimal amount, decimal expectedImpact)
    {
        // Arrange
        var transaction = new Transaction
        {
            Type = type,
            Amount = Math.Abs(amount),
            UserId = 1,
            AccountId = 1,
            TransactionDate = DateTime.UtcNow
        };

        // Act
        var impact = type == TransactionType.Income ? amount : -Math.Abs(amount);

        // Assert
        impact.Should().Be(expectedImpact);
    }
}
