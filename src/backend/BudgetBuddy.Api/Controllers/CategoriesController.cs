using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Infrastructure.Data;
using BudgetBuddy.Application.Categories;
using BudgetBuddy.Domain.Entities;

namespace BudgetBuddy.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly BudgetBuddyDbContext _context;
    private readonly ILogger<CategoriesController> _logger;

    public CategoriesController(BudgetBuddyDbContext context, ILogger<CategoriesController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetCategories([FromQuery] int userId = 1)
    {
        var categories = await _context.Categories
            .Where(c => c.UserId == userId && c.IsActive)
            .Select(c => new CategoryDto
            {
                CategoryId = c.CategoryId,
                CategoryName = c.CategoryName,
                CategoryType = c.CategoryType,
                ParentCategoryId = c.ParentCategoryId,
                Icon = c.Icon,
                Color = c.Color,
                IsActive = c.IsActive
            })
            .ToListAsync();

        return Ok(categories);
    }

    [HttpPost]
    public async Task<ActionResult<CategoryDto>> CreateCategory(CreateCategoryRequest request)
    {
        var category = new Category
        {
            UserId = request.UserId,
            CategoryName = request.CategoryName,
            CategoryType = request.CategoryType,
            ParentCategoryId = request.ParentCategoryId,
            Icon = request.Icon,
            Color = request.Color,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        var categoryDto = new CategoryDto
        {
            CategoryId = category.CategoryId,
            CategoryName = category.CategoryName,
            CategoryType = category.CategoryType,
            ParentCategoryId = category.ParentCategoryId,
            Icon = category.Icon,
            Color = category.Color,
            IsActive = category.IsActive
        };

        return CreatedAtAction(nameof(GetCategories), new { id = category.CategoryId }, categoryDto);
    }
}
