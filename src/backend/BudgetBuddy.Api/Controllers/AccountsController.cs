using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Infrastructure.Data;
using BudgetBuddy.Application.Accounts;
using BudgetBuddy.Domain.Entities;

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

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccounts([FromQuery] int userId = 1)
    {
        var accounts = await _context.Accounts
            .Where(a => a.UserId == userId && a.IsActive)
            .Select(a => new AccountDto
            {
                AccountId = a.AccountId,
                AccountName = a.AccountName,
                AccountType = a.AccountType,
                CurrentBalance = a.CurrentBalance,
                Currency = a.Currency,
                IsActive = a.IsActive
            })
            .ToListAsync();

        return Ok(accounts);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<AccountDto>> GetAccount(int id)
    {
        var account = await _context.Accounts
            .Where(a => a.AccountId == id)
            .Select(a => new AccountDto
            {
                AccountId = a.AccountId,
                AccountName = a.AccountName,
                AccountType = a.AccountType,
                CurrentBalance = a.CurrentBalance,
                Currency = a.Currency,
                IsActive = a.IsActive
            })
            .FirstOrDefaultAsync();

        if (account == null)
        {
            return NotFound();
        }

        return Ok(account);
    }

    [HttpPost]
    public async Task<ActionResult<AccountDto>> CreateAccount(CreateAccountRequest request)
    {
        var account = new Account
        {
            UserId = request.UserId,
            AccountName = request.AccountName,
            AccountType = request.AccountType,
            CurrentBalance = request.InitialBalance,
            Currency = request.Currency,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Accounts.Add(account);
        await _context.SaveChangesAsync();

        var accountDto = new AccountDto
        {
            AccountId = account.AccountId,
            AccountName = account.AccountName,
            AccountType = account.AccountType,
            CurrentBalance = account.CurrentBalance,
            Currency = account.Currency,
            IsActive = account.IsActive
        };

        return CreatedAtAction(nameof(GetAccount), new { id = account.AccountId }, accountDto);
    }
}
