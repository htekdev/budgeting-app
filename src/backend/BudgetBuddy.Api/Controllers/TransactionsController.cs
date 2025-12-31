using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Infrastructure.Data;
using BudgetBuddy.Application.Transactions;
using BudgetBuddy.Domain.Entities;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<TransactionsController> _logger;

    public TransactionsController(BudgetBuddyDbContext context, ILogger<TransactionsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactions(
        [FromQuery] int userId = 1,
        [FromQuery] DateTime? from = null,
        [FromQuery] DateTime? to = null,
        [FromQuery] int? accountId = null,
        [FromQuery] int? categoryId = null)
    {
        var query = _context.Transactions
            .Where(t => t.UserId == userId)
            .AsQueryable();

        if (from.HasValue)
            query = query.Where(t => t.TransactionDate >= from.Value);

        if (to.HasValue)
            query = query.Where(t => t.TransactionDate <= to.Value);

        if (accountId.HasValue)
            query = query.Where(t => t.AccountId == accountId.Value);

        if (categoryId.HasValue)
            query = query.Where(t => t.CategoryId == categoryId.Value);

        var transactions = await query
            .Include(t => t.Account)
            .Include(t => t.Category)
            .OrderByDescending(t => t.TransactionDate)
            .Select(t => new TransactionDto
            {
                TransactionId = t.TransactionId,
                AccountId = t.AccountId,
                AccountName = t.Account.AccountName,
                CategoryId = t.CategoryId,
                CategoryName = t.Category != null ? t.Category.CategoryName : null,
                TransactionType = t.TransactionType,
                Amount = t.Amount,
                TransactionDate = t.TransactionDate,
                Description = t.Description,
                Notes = t.Notes
            })
            .ToListAsync();

        return Ok(transactions);
    }

    [HttpPost]
    public async Task<ActionResult<TransactionDto>> CreateTransaction(CreateTransactionRequest request)
    {
        var transaction = new Transaction
        {
            UserId = request.UserId,
            AccountId = request.AccountId,
            CategoryId = request.CategoryId,
            TransactionType = request.TransactionType,
            Amount = request.Amount,
            TransactionDate = request.TransactionDate,
            Description = request.Description,
            Notes = request.Notes,
            ToAccountId = request.ToAccountId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        // Reload with navigation properties
        var transactionDto = await _context.Transactions
            .Include(t => t.Account)
            .Include(t => t.Category)
            .Where(t => t.TransactionId == transaction.TransactionId)
            .Select(t => new TransactionDto
            {
                TransactionId = t.TransactionId,
                AccountId = t.AccountId,
                AccountName = t.Account.AccountName,
                CategoryId = t.CategoryId,
                CategoryName = t.Category != null ? t.Category.CategoryName : null,
                TransactionType = t.TransactionType,
                Amount = t.Amount,
                TransactionDate = t.TransactionDate,
                Description = t.Description,
                Notes = t.Notes
            })
            .FirstAsync();

        return CreatedAtAction(nameof(GetTransactions), new { id = transaction.TransactionId }, transactionDto);
    }
}
