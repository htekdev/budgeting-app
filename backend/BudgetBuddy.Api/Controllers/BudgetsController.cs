using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Api.Data;
using BudgetBuddy.Api.DTOs;
using BudgetBuddy.Api.Models;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BudgetsController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<BudgetsController> _logger;

    public BudgetsController(BudgetBuddyDbContext context, ILogger<BudgetsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<BudgetDto>>> GetBudgets([FromQuery] string? userId = null)
    {
        _logger.LogInformation("Fetching budgets for user: {UserId}", userId ?? "all");
        
        var query = _context.Budgets.AsQueryable();
        
        if (!string.IsNullOrEmpty(userId))
        {
            query = query.Where(b => b.UserId == userId);
        }

        var budgets = await query
            .Select(b => new BudgetDto(
                b.Id,
                b.Name,
                b.TotalAmount,
                b.StartDate,
                b.EndDate,
                b.UserId,
                b.CreatedAt,
                b.UpdatedAt
            ))
            .ToListAsync();

        return Ok(budgets);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<BudgetDto>> GetBudget(int id)
    {
        _logger.LogInformation("Fetching budget with ID: {BudgetId}", id);
        
        var budget = await _context.Budgets
            .Where(b => b.Id == id)
            .Select(b => new BudgetDto(
                b.Id,
                b.Name,
                b.TotalAmount,
                b.StartDate,
                b.EndDate,
                b.UserId,
                b.CreatedAt,
                b.UpdatedAt
            ))
            .FirstOrDefaultAsync();

        if (budget == null)
        {
            _logger.LogWarning("Budget with ID {BudgetId} not found", id);
            return NotFound();
        }

        return Ok(budget);
    }

    [HttpPost]
    public async Task<ActionResult<BudgetDto>> CreateBudget(CreateBudgetDto dto)
    {
        _logger.LogInformation("Creating new budget: {BudgetName}", dto.Name);
        
        var budget = new Budget
        {
            Name = dto.Name,
            TotalAmount = dto.TotalAmount,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate,
            UserId = dto.UserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Budgets.Add(budget);
        await _context.SaveChangesAsync();

        var budgetDto = new BudgetDto(
            budget.Id,
            budget.Name,
            budget.TotalAmount,
            budget.StartDate,
            budget.EndDate,
            budget.UserId,
            budget.CreatedAt,
            budget.UpdatedAt
        );

        return CreatedAtAction(nameof(GetBudget), new { id = budget.Id }, budgetDto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBudget(int id, UpdateBudgetDto dto)
    {
        _logger.LogInformation("Updating budget with ID: {BudgetId}", id);
        
        var budget = await _context.Budgets.FindAsync(id);
        if (budget == null)
        {
            _logger.LogWarning("Budget with ID {BudgetId} not found", id);
            return NotFound();
        }

        budget.Name = dto.Name;
        budget.TotalAmount = dto.TotalAmount;
        budget.StartDate = dto.StartDate;
        budget.EndDate = dto.EndDate;
        budget.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBudget(int id)
    {
        _logger.LogInformation("Deleting budget with ID: {BudgetId}", id);
        
        var budget = await _context.Budgets.FindAsync(id);
        if (budget == null)
        {
            _logger.LogWarning("Budget with ID {BudgetId} not found", id);
            return NotFound();
        }

        _context.Budgets.Remove(budget);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
