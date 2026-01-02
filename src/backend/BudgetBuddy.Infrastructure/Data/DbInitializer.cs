using BudgetBuddy.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace BudgetBuddy.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(BudgetBuddyDbContext context)
    {
        // Ensure database is created
        await context.Database.EnsureCreatedAsync();

        // Check if already seeded
        if (await context.Users.AnyAsync())
        {
            return;
        }

        // Seed demo user
        var demoUser = new User
        {
            Id = Guid.NewGuid(),
            Email = "demo@budgetbuddy.com",
            DisplayName = "Demo User",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await context.Users.AddAsync(demoUser);
        await context.SaveChangesAsync();

        // Seed demo budget
        var demoBudget = new Budget
        {
            Id = Guid.NewGuid(),
            Name = "Monthly Budget - January 2026",
            Description = "Demo budget for January 2026",
            TotalAmount = 5000m,
            StartDate = new DateTime(2026, 1, 1),
            EndDate = new DateTime(2026, 1, 31),
            UserId = demoUser.Id,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await context.Budgets.AddAsync(demoBudget);
        await context.SaveChangesAsync();

        // Seed categories
        var categories = new[]
        {
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Housing",
                Description = "Rent, mortgage, utilities",
                Color = "#FF6B6B",
                Icon = "home",
                AllocatedAmount = 1500m,
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Food & Groceries",
                Description = "Groceries and dining",
                Color = "#4ECDC4",
                Icon = "shopping-cart",
                AllocatedAmount = 800m,
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Transportation",
                Description = "Gas, car payment, transit",
                Color = "#45B7D1",
                Icon = "car",
                AllocatedAmount = 500m,
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Entertainment",
                Description = "Movies, games, hobbies",
                Color = "#F7DC6F",
                Icon = "star",
                AllocatedAmount = 300m,
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Savings",
                Description = "Emergency fund and investments",
                Color = "#95E1D3",
                Icon = "piggy-bank",
                AllocatedAmount = 1000m,
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            }
        };

        await context.Categories.AddRangeAsync(categories);
        await context.SaveChangesAsync();

        // Seed transactions
        var transactions = new[]
        {
            new Transaction
            {
                Id = Guid.NewGuid(),
                Description = "Monthly Salary",
                Amount = 5000m,
                TransactionDate = new DateTime(2026, 1, 1),
                Type = TransactionType.Income,
                Notes = "January salary deposit",
                BudgetId = demoBudget.Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Transaction
            {
                Id = Guid.NewGuid(),
                Description = "Rent Payment",
                Amount = 1200m,
                TransactionDate = new DateTime(2026, 1, 2),
                Type = TransactionType.Expense,
                Notes = "January rent",
                BudgetId = demoBudget.Id,
                CategoryId = categories[0].Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Transaction
            {
                Id = Guid.NewGuid(),
                Description = "Grocery Shopping",
                Amount = 150m,
                TransactionDate = new DateTime(2026, 1, 5),
                Type = TransactionType.Expense,
                Notes = "Weekly groceries",
                BudgetId = demoBudget.Id,
                CategoryId = categories[1].Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Transaction
            {
                Id = Guid.NewGuid(),
                Description = "Gas Station",
                Amount = 60m,
                TransactionDate = new DateTime(2026, 1, 7),
                Type = TransactionType.Expense,
                Notes = "Fill up tank",
                BudgetId = demoBudget.Id,
                CategoryId = categories[2].Id,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            }
        };

        await context.Transactions.AddRangeAsync(transactions);
        await context.SaveChangesAsync();
    }
}
