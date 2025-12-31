using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Domain.Entities;

namespace BudgetBuddy.Infrastructure.Data;

public class BudgetBuddyDbContext : DbContext
{
    public BudgetBuddyDbContext(DbContextOptions<BudgetBuddyDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<Account> Accounts { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<Budget> Budgets { get; set; }
    public DbSet<RecurringTransaction> RecurringTransactions { get; set; }
    public DbSet<Goal> Goals { get; set; }
    public DbSet<AuditEvent> AuditEvents { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Email).HasMaxLength(255).IsRequired();
            entity.Property(e => e.FirstName).HasMaxLength(100).IsRequired();
            entity.Property(e => e.LastName).HasMaxLength(100).IsRequired();
        });

        // Account configuration
        modelBuilder.Entity<Account>(entity =>
        {
            entity.HasKey(e => e.AccountId);
            entity.Property(e => e.AccountName).HasMaxLength(200).IsRequired();
            entity.Property(e => e.AccountType).HasMaxLength(50).IsRequired();
            entity.Property(e => e.CurrentBalance).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Currency).HasMaxLength(3);

            entity.HasOne(e => e.User)
                .WithMany(u => u.Accounts)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Category configuration
        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId);
            entity.Property(e => e.CategoryName).HasMaxLength(100).IsRequired();
            entity.Property(e => e.CategoryType).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Icon).HasMaxLength(50);
            entity.Property(e => e.Color).HasMaxLength(7);

            entity.HasOne(e => e.User)
                .WithMany(u => u.Categories)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.ParentCategory)
                .WithMany(c => c.SubCategories)
                .HasForeignKey(e => e.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => new { e.UserId, e.CategoryName }).IsUnique();
        });

        // Transaction configuration
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.TransactionId);
            entity.Property(e => e.TransactionType).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.TransactionDate).HasColumnType("date");

            entity.HasOne(e => e.User)
                .WithMany(u => u.Transactions)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Account)
                .WithMany(a => a.Transactions)
                .HasForeignKey(e => e.AccountId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Category)
                .WithMany(c => c.Transactions)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.ToAccount)
                .WithMany()
                .HasForeignKey(e => e.ToAccountId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.RecurringTransaction)
                .WithMany(r => r.GeneratedTransactions)
                .HasForeignKey(e => e.RecurringTransactionId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Budget configuration
        modelBuilder.Entity<Budget>(entity =>
        {
            entity.HasKey(e => e.BudgetId);
            entity.Property(e => e.BudgetAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.BudgetMonth).HasColumnType("date");

            entity.HasOne(e => e.User)
                .WithMany(u => u.Budgets)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Category)
                .WithMany(c => c.Budgets)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => new { e.UserId, e.CategoryId, e.BudgetMonth }).IsUnique();
        });

        // RecurringTransaction configuration
        modelBuilder.Entity<RecurringTransaction>(entity =>
        {
            entity.HasKey(e => e.RecurringTransactionId);
            entity.Property(e => e.TransactionType).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Description).HasMaxLength(500).IsRequired();
            entity.Property(e => e.Frequency).HasMaxLength(20).IsRequired();
            entity.Property(e => e.StartDate).HasColumnType("date");
            entity.Property(e => e.EndDate).HasColumnType("date");
            entity.Property(e => e.LastGeneratedDate).HasColumnType("date");

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Account)
                .WithMany(a => a.RecurringTransactions)
                .HasForeignKey(e => e.AccountId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Category)
                .WithMany()
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Goal configuration
        modelBuilder.Entity<Goal>(entity =>
        {
            entity.HasKey(e => e.GoalId);
            entity.Property(e => e.GoalName).HasMaxLength(200).IsRequired();
            entity.Property(e => e.TargetAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.CurrentAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.TargetDate).HasColumnType("date");

            entity.HasOne(e => e.User)
                .WithMany(u => u.Goals)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Account)
                .WithMany()
                .HasForeignKey(e => e.AccountId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // AuditEvent configuration
        modelBuilder.Entity<AuditEvent>(entity =>
        {
            entity.HasKey(e => e.AuditEventId);
            entity.Property(e => e.EntityType).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Action).HasMaxLength(20).IsRequired();
            entity.Property(e => e.IpAddress).HasMaxLength(45);
            entity.Property(e => e.UserAgent).HasMaxLength(500);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
