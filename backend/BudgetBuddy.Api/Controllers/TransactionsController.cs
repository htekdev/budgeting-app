using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Api.Data;
using BudgetBuddy.Api.DTOs;
using BudgetBuddy.Api.Models;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
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
    public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactions([FromQuery] int? budgetId = null)
    {
        _logger.LogInformation("Fetching transactions for budget: {BudgetId}", budgetId?.ToString() ?? "all");
        
        var query = _context.Transactions.AsQueryable();
        
        if (budgetId.HasValue)
        {
            query = query.Where(t => t.BudgetId == budgetId.Value);
        }

        var transactions = await query
            .Select(t => new TransactionDto(
                t.Id,
                t.Description,
                t.Amount,
                t.Date,
                t.Type.ToString(),
                t.BudgetId,
                t.CategoryId,
                t.CreatedAt
            ))
            .ToListAsync();

        return Ok(transactions);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TransactionDto>> GetTransaction(int id)
    {
        _logger.LogInformation("Fetching transaction with ID: {TransactionId}", id);
        
        var transaction = await _context.Transactions
            .Where(t => t.Id == id)
            .Select(t => new TransactionDto(
                t.Id,
                t.Description,
                t.Amount,
                t.Date,
                t.Type.ToString(),
                t.BudgetId,
                t.CategoryId,
                t.CreatedAt
            ))
            .FirstOrDefaultAsync();

        if (transaction == null)
        {
            _logger.LogWarning("Transaction with ID {TransactionId} not found", id);
            return NotFound();
        }

        return Ok(transaction);
    }

    [HttpPost]
    public async Task<ActionResult<TransactionDto>> CreateTransaction(CreateTransactionDto dto)
    {
        _logger.LogInformation("Creating new transaction: {Description}", dto.Description);
        
        if (!Enum.TryParse<TransactionType>(dto.Type, true, out var transactionType))
        {
            return BadRequest("Invalid transaction type");
        }

        var transaction = new Transaction
        {
            Description = dto.Description,
            Amount = dto.Amount,
            Date = dto.Date,
            Type = transactionType,
            BudgetId = dto.BudgetId,
            CategoryId = dto.CategoryId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        var transactionDto = new TransactionDto(
            transaction.Id,
            transaction.Description,
            transaction.Amount,
            transaction.Date,
            transaction.Type.ToString(),
            transaction.BudgetId,
            transaction.CategoryId,
            transaction.CreatedAt
        );

        return CreatedAtAction(nameof(GetTransaction), new { id = transaction.Id }, transactionDto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTransaction(int id, UpdateTransactionDto dto)
    {
        _logger.LogInformation("Updating transaction with ID: {TransactionId}", id);
        
        var transaction = await _context.Transactions.FindAsync(id);
        if (transaction == null)
        {
            _logger.LogWarning("Transaction with ID {TransactionId} not found", id);
            return NotFound();
        }

        if (!Enum.TryParse<TransactionType>(dto.Type, true, out var transactionType))
        {
            return BadRequest("Invalid transaction type");
        }

        transaction.Description = dto.Description;
        transaction.Amount = dto.Amount;
        transaction.Date = dto.Date;
        transaction.Type = transactionType;
        transaction.CategoryId = dto.CategoryId;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTransaction(int id)
    {
        _logger.LogInformation("Deleting transaction with ID: {TransactionId}", id);
        
        var transaction = await _context.Transactions.FindAsync(id);
        if (transaction == null)
        {
            _logger.LogWarning("Transaction with ID {TransactionId} not found", id);
            return NotFound();
        }

        _context.Transactions.Remove(transaction);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
