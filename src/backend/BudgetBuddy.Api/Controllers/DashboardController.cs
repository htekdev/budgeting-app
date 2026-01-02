using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Infrastructure.Data;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(BudgetBuddyDbContext context, ILogger<DashboardController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get dashboard summary data for the current user
    /// </summary>
    [HttpGet("summary")]
    public async Task<ActionResult<DashboardSummaryDto>> GetDashboardSummary([FromQuery] int userId = 1)
    {
        try
        {
            // Get all active accounts for the user
            var accounts = await _context.Accounts
                .Where(a => a.UserId == userId && a.IsActive)
                .ToListAsync();

            // Calculate total balance
            var totalBalance = accounts.Sum(a => a.Balance);

            // Get current month's transactions
            var currentMonth = DateTime.UtcNow;
            var monthStart = new DateTime(currentMonth.Year, currentMonth.Month, 1);
            var monthEnd = monthStart.AddMonths(1);

            var monthlyTransactions = await _context.Transactions
                .Where(t => t.UserId == userId && t.TransactionDate >= monthStart && t.TransactionDate < monthEnd)
                .ToListAsync();

            var monthlySpending = monthlyTransactions
                .Where(t => t.Type == BudgetBuddy.Domain.Enums.TransactionType.Expense)
                .Sum(t => t.Amount);

            // Get active goals
            var activeGoals = await _context.Goals
                .Where(g => g.UserId == userId && !g.IsCompleted)
                .ToListAsync();

            var goalsProgress = activeGoals.Any()
                ? (int)(activeGoals.Average(g => (g.CurrentAmount / g.TargetAmount) * 100))
                : 0;

            // Get upcoming bills (recurring transactions due in next 7 days)
            var upcomingDate = DateTime.UtcNow.AddDays(7);
            var upcomingBills = await _context.RecurringTransactions
                .Where(rt => rt.UserId == userId && rt.IsActive && rt.NextOccurrence <= upcomingDate)
                .ToListAsync();

            var upcomingAmount = upcomingBills.Sum(b => b.Amount);

            // Get recent transactions
            var recentTransactions = await _context.Transactions
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.TransactionDate)
                .Take(5)
                .ToListAsync();

            var summary = new DashboardSummaryDto
            {
                TotalBalance = totalBalance,
                MonthlySpending = monthlySpending,
                GoalsProgress = goalsProgress,
                ActiveGoalsCount = activeGoals.Count,
                UpcomingBills = upcomingAmount,
                RecentTransactions = recentTransactions.Select(t => new TransactionDto
                {
                    Id = t.Id,
                    Description = t.Description ?? "Transaction",
                    Amount = t.Type == BudgetBuddy.Domain.Enums.TransactionType.Expense ? -t.Amount : t.Amount,
                    TransactionDate = t.TransactionDate,
                    Type = t.Type.ToString()
                }).ToList()
            };

            return Ok(summary);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving dashboard summary for user {UserId}", userId);
            return StatusCode(500, new { error = "An error occurred while retrieving dashboard data" });
        }
    }
}

public class DashboardSummaryDto
{
    public decimal TotalBalance { get; set; }
    public decimal MonthlySpending { get; set; }
    public int GoalsProgress { get; set; }
    public int ActiveGoalsCount { get; set; }
    public decimal UpcomingBills { get; set; }
    public List<TransactionDto> RecentTransactions { get; set; } = new();
}

public class TransactionDto
{
    public int Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public string Type { get; set; } = string.Empty;
}
