using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Api.Models;

namespace BudgetBuddy.Api.Data;

public class BudgetBuddyDbContext : DbContext
{
    public BudgetBuddyDbContext(DbContextOptions<BudgetBuddyDbContext> options)
        : base(options)
    {
    }

    public DbSet<Budget> Budgets { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Transaction> Transactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Budget>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.UserId).IsRequired().HasMaxLength(100);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.HasMany(e => e.Categories)
                .WithOne(e => e.Budget)
                .HasForeignKey(e => e.BudgetId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(e => e.Transactions)
                .WithOne(e => e.Budget)
                .HasForeignKey(e => e.BudgetId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Color).IsRequired().HasMaxLength(20);
            entity.Property(e => e.AllocatedAmount).HasColumnType("decimal(18,2)");
            entity.HasMany(e => e.Transactions)
                .WithOne(e => e.Category)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Description).IsRequired().HasMaxLength(500);
            entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Type).HasConversion<string>();
        });

        // Seed data
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        var budget1 = new Budget
        {
            Id = 1,
            Name = "Monthly Budget - January 2026",
            TotalAmount = 5000m,
            StartDate = new DateTime(2026, 1, 1),
            EndDate = new DateTime(2026, 1, 31),
            UserId = "demo-user",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var categories = new[]
        {
            new Category { Id = 1, Name = "Groceries", AllocatedAmount = 800m, Color = "#4CAF50", BudgetId = 1 },
            new Category { Id = 2, Name = "Transportation", AllocatedAmount = 400m, Color = "#2196F3", BudgetId = 1 },
            new Category { Id = 3, Name = "Entertainment", AllocatedAmount = 300m, Color = "#FF9800", BudgetId = 1 },
            new Category { Id = 4, Name = "Utilities", AllocatedAmount = 500m, Color = "#9C27B0", BudgetId = 1 },
            new Category { Id = 5, Name = "Healthcare", AllocatedAmount = 200m, Color = "#F44336", BudgetId = 1 }
        };

        var transactions = new[]
        {
            new Transaction { Id = 1, Description = "Salary", Amount = 5000m, Date = new DateTime(2026, 1, 1), Type = TransactionType.Income, BudgetId = 1, CreatedAt = DateTime.UtcNow },
            new Transaction { Id = 2, Description = "Grocery Store", Amount = 120.50m, Date = new DateTime(2026, 1, 3), Type = TransactionType.Expense, BudgetId = 1, CategoryId = 1, CreatedAt = DateTime.UtcNow },
            new Transaction { Id = 3, Description = "Gas Station", Amount = 45.00m, Date = new DateTime(2026, 1, 5), Type = TransactionType.Expense, BudgetId = 1, CategoryId = 2, CreatedAt = DateTime.UtcNow },
            new Transaction { Id = 4, Description = "Movie Tickets", Amount = 30.00m, Date = new DateTime(2026, 1, 7), Type = TransactionType.Expense, BudgetId = 1, CategoryId = 3, CreatedAt = DateTime.UtcNow },
            new Transaction { Id = 5, Description = "Electric Bill", Amount = 150.00m, Date = new DateTime(2026, 1, 10), Type = TransactionType.Expense, BudgetId = 1, CategoryId = 4, CreatedAt = DateTime.UtcNow }
        };

        modelBuilder.Entity<Budget>().HasData(budget1);
        modelBuilder.Entity<Category>().HasData(categories);
        modelBuilder.Entity<Transaction>().HasData(transactions);
    }
}
