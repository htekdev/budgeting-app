using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Domain.Entities;
using BudgetBuddy.Infrastructure.Data;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class AccountsController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<AccountsController> _logger;

    public AccountsController(BudgetBuddyDbContext context, ILogger<AccountsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all accounts for the current user
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Account>>> GetAccounts([FromQuery] int userId = 1)
    {
        try
        {
            var accounts = await _context.Accounts
                .Where(a => a.UserId == userId && a.IsActive)
                .OrderBy(a => a.Name)
                .ToListAsync();

            return Ok(accounts);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving accounts for user {UserId}", userId);
            return StatusCode(500, new { error = "An error occurred while retrieving accounts" });
        }
    }

    /// <summary>
    /// Get a specific account by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Account>> GetAccount(int id, [FromQuery] int userId = 1)
    {
        try
        {
            var account = await _context.Accounts
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

            if (account == null)
            {
                return NotFound(new { error = "Account not found" });
            }

            return Ok(account);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving account {AccountId} for user {UserId}", id, userId);
            return StatusCode(500, new { error = "An error occurred while retrieving the account" });
        }
    }

    /// <summary>
    /// Create a new account
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Account>> CreateAccount([FromBody] Account account)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            account.CreatedAt = DateTime.UtcNow;
            account.UpdatedAt = DateTime.UtcNow;

            _context.Accounts.Add(account);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Created account {AccountId} for user {UserId}", account.Id, account.UserId);

            return CreatedAtAction(nameof(GetAccount), new { id = account.Id, userId = account.UserId }, account);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating account for user {UserId}", account.UserId);
            return StatusCode(500, new { error = "An error occurred while creating the account" });
        }
    }

    /// <summary>
    /// Update an existing account
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateAccount(int id, [FromBody] Account account, [FromQuery] int userId = 1)
    {
        try
        {
            if (id != account.Id)
            {
                return BadRequest(new { error = "Account ID mismatch" });
            }

            var existingAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

            if (existingAccount == null)
            {
                return NotFound(new { error = "Account not found" });
            }

            existingAccount.Name = account.Name;
            existingAccount.Type = account.Type;
            existingAccount.Balance = account.Balance;
            existingAccount.Currency = account.Currency;
            existingAccount.IsActive = account.IsActive;
            existingAccount.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation("Updated account {AccountId} for user {UserId}", id, userId);

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating account {AccountId} for user {UserId}", id, userId);
            return StatusCode(500, new { error = "An error occurred while updating the account" });
        }
    }

    /// <summary>
    /// Delete an account (soft delete)
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAccount(int id, [FromQuery] int userId = 1)
    {
        try
        {
            var account = await _context.Accounts
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

            if (account == null)
            {
                return NotFound(new { error = "Account not found" });
            }

            account.IsActive = false;
            account.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation("Deleted account {AccountId} for user {UserId}", id, userId);

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting account {AccountId} for user {UserId}", id, userId);
            return StatusCode(500, new { error = "An error occurred while deleting the account" });
        }
    }
}
