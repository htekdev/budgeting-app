using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Api.Data;
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

    /// <summary>
    /// Get all budgets
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Budget>>> GetBudgets()
    {
        try
        {
            var budgets = await _context.Budgets
                .Include(b => b.Category)
                .ToListAsync();
            return Ok(budgets);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving budgets");
            return StatusCode(500, "An error occurred while retrieving budgets");
        }
    }

    /// <summary>
    /// Get a specific budget by id
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Budget>> GetBudget(int id)
    {
        try
        {
            var budget = await _context.Budgets
                .Include(b => b.Category)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (budget == null)
            {
                return NotFound();
            }

            return Ok(budget);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving budget {BudgetId}", id);
            return StatusCode(500, "An error occurred while retrieving the budget");
        }
    }

    /// <summary>
    /// Create a new budget
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Budget>> CreateBudget(Budget budget)
    {
        try
        {
            _context.Budgets.Add(budget);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetBudget), new { id = budget.Id }, budget);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating budget");
            return StatusCode(500, "An error occurred while creating the budget");
        }
    }
}
