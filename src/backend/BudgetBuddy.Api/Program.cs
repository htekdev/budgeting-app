using Microsoft.EntityFrameworkCore;
using Swashbuckle.AspNetCore.SwaggerGen;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using BudgetBuddy.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add DbContext
builder.Services.AddDbContext<BudgetBuddyDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions => sqlOptions.EnableRetryOnFailure()
    )
);

// Add CORS - completely permissive for development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<BudgetBuddyDbContext>();

// Add logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "BudgetBuddy API V1");
    });
}

app.UseCors();  // Uses the default policy - allows all origins with credentials

// Only redirect to HTTPS in production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// Run migrations in development
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<BudgetBuddyDbContext>();
    try
    {
        await db.Database.MigrateAsync();
        app.Logger.LogInformation("Database migrations applied successfully");

        // Seed data if database is empty
        if (!await db.Users.AnyAsync())
        {
            var user = new BudgetBuddy.Domain.Entities.User
            {
                Username = "demo",
                Email = "demo@budgetbuddy.local",
                PasswordHash = "hashed_password_here",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            db.Users.Add(user);
            await db.SaveChangesAsync();

            // Add accounts
            var accounts = new[]
            {
                new BudgetBuddy.Domain.Entities.Account
                {
                    UserId = user.Id,
                    Name = "Checking Account",
                    Type = BudgetBuddy.Domain.Enums.AccountType.Checking,
                    Balance = 8500.00m,
                    Currency = "USD",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                },
                new BudgetBuddy.Domain.Entities.Account
                {
                    UserId = user.Id,
                    Name = "Savings Account",
                    Type = BudgetBuddy.Domain.Enums.AccountType.Savings,
                    Balance = 10700.00m,
                    Currency = "USD",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                }
            };

            db.Accounts.AddRange(accounts);
            await db.SaveChangesAsync();

            // Add categories
            var categories = new[]
            {
                new BudgetBuddy.Domain.Entities.Category
                {
                    UserId = user.Id,
                    Name = "Groceries",
                    Type = BudgetBuddy.Domain.Enums.CategoryType.Expense,
                    Icon = "🛒",
                    Color = "#FF6B6B",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                },
                new BudgetBuddy.Domain.Entities.Category
                {
                    UserId = user.Id,
                    Name = "Rent",
                    Type = BudgetBuddy.Domain.Enums.CategoryType.Expense,
                    Icon = "🏠",
                    Color = "#4ECDC4",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                },
                new BudgetBuddy.Domain.Entities.Category
                {
                    UserId = user.Id,
                    Name = "Salary",
                    Type = BudgetBuddy.Domain.Enums.CategoryType.Income,
                    Icon = "💼",
                    Color = "#45B7D1",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                }
            };

            db.Categories.AddRange(categories);
            await db.SaveChangesAsync();

            // Add transactions
            var now = DateTime.UtcNow;
            var thisMonth = new DateTime(now.Year, now.Month, 1);
            var transactions = new[]
            {
                new BudgetBuddy.Domain.Entities.Transaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[2].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Income,
                    Amount = 5000.00m,
                    Description = "Monthly Salary",
                    TransactionDate = thisMonth.AddDays(-6),
                    CreatedAt = thisMonth.AddDays(-6),
                    UpdatedAt = thisMonth.AddDays(-6)
                },
                new BudgetBuddy.Domain.Entities.Transaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[1].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 1500.00m,
                    Description = "Rent Payment",
                    TransactionDate = thisMonth.AddDays(-5),
                    CreatedAt = thisMonth.AddDays(-5),
                    UpdatedAt = thisMonth.AddDays(-5)
                },
                new BudgetBuddy.Domain.Entities.Transaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[0].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 78.50m,
                    Description = "Grocery Shopping",
                    TransactionDate = now,
                    CreatedAt = now,
                    UpdatedAt = now
                },
                new BudgetBuddy.Domain.Entities.Transaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[0].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 45.25m,
                    Description = "Coffee Shop",
                    TransactionDate = now.AddDays(-2),
                    CreatedAt = now.AddDays(-2),
                    UpdatedAt = now.AddDays(-2)
                },
                new BudgetBuddy.Domain.Entities.Transaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[0].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 125.00m,
                    Description = "Weekly Groceries",
                    TransactionDate = now.AddDays(-4),
                    CreatedAt = now.AddDays(-4),
                    UpdatedAt = now.AddDays(-4)
                }
            };

            db.Transactions.AddRange(transactions);
            await db.SaveChangesAsync();

            // Add goals
            var goals = new[]
            {
                new BudgetBuddy.Domain.Entities.Goal
                {
                    UserId = user.Id,
                    Name = "Vacation Fund",
                    TargetAmount = 5000.00m,
                    CurrentAmount = 3500.00m,
                    TargetDate = now.AddMonths(6),
                    Description = "Save for summer vacation",
                    IsCompleted = false,
                    CreatedAt = now,
                    UpdatedAt = now
                },
                new BudgetBuddy.Domain.Entities.Goal
                {
                    UserId = user.Id,
                    Name = "Emergency Fund",
                    TargetAmount = 15000.00m,
                    CurrentAmount = 10700.00m,
                    TargetDate = now.AddMonths(12),
                    Description = "6 months of expenses",
                    IsCompleted = false,
                    CreatedAt = now,
                    UpdatedAt = now
                },
                new BudgetBuddy.Domain.Entities.Goal
                {
                    UserId = user.Id,
                    Name = "New Laptop",
                    TargetAmount = 2000.00m,
                    CurrentAmount = 1500.00m,
                    TargetDate = now.AddMonths(3),
                    Description = "Save for work laptop upgrade",
                    IsCompleted = false,
                    CreatedAt = now,
                    UpdatedAt = now
                }
            };

            db.Goals.AddRange(goals);
            await db.SaveChangesAsync();

            // Add recurring transactions (bills)
            var recurringTransactions = new[]
            {
                new BudgetBuddy.Domain.Entities.RecurringTransaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    CategoryId = categories[1].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 1500.00m,
                    Description = "Monthly Rent",
                    Frequency = BudgetBuddy.Domain.Enums.RecurrenceFrequency.Monthly,
                    StartDate = thisMonth,
                    NextOccurrence = thisMonth.AddMonths(1),
                    IsActive = true,
                    CreatedAt = now,
                    UpdatedAt = now
                },
                new BudgetBuddy.Domain.Entities.RecurringTransaction
                {
                    UserId = user.Id,
                    AccountId = accounts[0].Id,
                    Type = BudgetBuddy.Domain.Enums.TransactionType.Expense,
                    Amount = 50.00m,
                    Description = "Internet Bill",
                    Frequency = BudgetBuddy.Domain.Enums.RecurrenceFrequency.Monthly,
                    StartDate = thisMonth.AddDays(5),
                    NextOccurrence = thisMonth.AddDays(5).AddDays(3),
                    IsActive = true,
                    CreatedAt = now,
                    UpdatedAt = now
                }
            };

            db.RecurringTransactions.AddRange(recurringTransactions);
            await db.SaveChangesAsync();

            app.Logger.LogInformation("Database seeded with sample data");
        }
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "An error occurred while applying database migrations or seeding data");
    }
}

app.Run();
