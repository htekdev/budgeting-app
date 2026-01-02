using BudgetBuddy.Domain.Entities;
using BudgetBuddy.Infrastructure.Data;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container
builder.Services.AddDbContext<BudgetBuddyDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection") 
        ?? "Server=localhost;Database=BudgetBuddyDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"));

builder.Services.AddOpenApi();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<BudgetBuddyDbContext>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "BudgetBuddy API v1");
    });
}

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BudgetBuddyDbContext>();
    await context.Database.MigrateAsync();
    await DbInitializer.SeedAsync(context);
}

app.UseHttpsRedirection();
app.UseCors("AllowFrontend");
app.UseSerilogRequestLogging();

// Map health check endpoint
app.MapHealthChecks("/health");

// Budget endpoints
app.MapGet("/api/budgets", async (BudgetBuddyDbContext db, int page = 1, int pageSize = 10) =>
{
    var budgets = await db.Budgets
        .Include(b => b.User)
        .Include(b => b.Categories)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
    
    return Results.Ok(budgets);
})
.WithName("GetBudgets")
.WithTags("Budgets");


app.MapGet("/api/budgets/{id:guid}", async (Guid id, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets
        .Include(b => b.User)
        .Include(b => b.Categories)
        .Include(b => b.Transactions)
        .FirstOrDefaultAsync(b => b.Id == id);

    return budget is not null ? Results.Ok(budget) : Results.NotFound();
})
.WithName("GetBudgetById")
.WithTags("Budgets");


app.MapPost("/api/budgets", async (Budget budget, BudgetBuddyDbContext db) =>
{
    budget.Id = Guid.NewGuid();
    budget.CreatedAt = DateTime.UtcNow;
    budget.UpdatedAt = DateTime.UtcNow;

    db.Budgets.Add(budget);
    await db.SaveChangesAsync();

    return Results.Created($"/api/budgets/{budget.Id}", budget);
})
.WithName("CreateBudget")
.WithTags("Budgets");


app.MapPut("/api/budgets/{id:guid}", async (Guid id, Budget inputBudget, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets.FindAsync(id);
    if (budget is null) return Results.NotFound();

    budget.Name = inputBudget.Name;
    budget.Description = inputBudget.Description;
    budget.TotalAmount = inputBudget.TotalAmount;
    budget.StartDate = inputBudget.StartDate;
    budget.EndDate = inputBudget.EndDate;
    budget.UpdatedAt = DateTime.UtcNow;

    await db.SaveChangesAsync();
    return Results.Ok(budget);
})
.WithName("UpdateBudget")
.WithTags("Budgets");


app.MapDelete("/api/budgets/{id:guid}", async (Guid id, BudgetBuddyDbContext db) =>
{
    var budget = await db.Budgets.FindAsync(id);
    if (budget is null) return Results.NotFound();

    db.Budgets.Remove(budget);
    await db.SaveChangesAsync();
    return Results.NoContent();
})
.WithName("DeleteBudget")
.WithTags("Budgets");


// Transaction endpoints
app.MapGet("/api/budgets/{budgetId:guid}/transactions", async (Guid budgetId, BudgetBuddyDbContext db, int page = 1, int pageSize = 20) =>
{
    var transactions = await db.Transactions
        .Include(t => t.Category)
        .Where(t => t.BudgetId == budgetId)
        .OrderByDescending(t => t.TransactionDate)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();

    return Results.Ok(transactions);
})
.WithName("GetTransactions")
.WithTags("Transactions");


app.MapPost("/api/transactions", async (Transaction transaction, BudgetBuddyDbContext db) =>
{
    transaction.Id = Guid.NewGuid();
    transaction.CreatedAt = DateTime.UtcNow;
    transaction.UpdatedAt = DateTime.UtcNow;

    db.Transactions.Add(transaction);
    await db.SaveChangesAsync();

    return Results.Created($"/api/transactions/{transaction.Id}", transaction);
})
.WithName("CreateTransaction")
.WithTags("Transactions");


// Category endpoints
app.MapGet("/api/budgets/{budgetId:guid}/categories", async (Guid budgetId, BudgetBuddyDbContext db) =>
{
    var categories = await db.Categories
        .Where(c => c.BudgetId == budgetId)
        .ToListAsync();

    return Results.Ok(categories);
})
.WithName("GetCategories")
.WithTags("Categories");


app.MapPost("/api/categories", async (Category category, BudgetBuddyDbContext db) =>
{
    category.Id = Guid.NewGuid();
    category.CreatedAt = DateTime.UtcNow;
    category.UpdatedAt = DateTime.UtcNow;

    db.Categories.Add(category);
    await db.SaveChangesAsync();

    return Results.Created($"/api/categories/{category.Id}", category);
})
.WithName("CreateCategory")
.WithTags("Categories");


// User endpoints
app.MapGet("/api/users", async (BudgetBuddyDbContext db) =>
{
    var users = await db.Users.ToListAsync();
    return Results.Ok(users);
})
.WithName("GetUsers")
.WithTags("Users");


try
{
    Log.Information("Starting BudgetBuddy API");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
