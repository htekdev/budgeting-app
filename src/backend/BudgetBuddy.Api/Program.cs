using Microsoft.EntityFrameworkCore;
using BudgetBuddy.Infrastructure.Data;
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
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title = "BudgetBuddy API",
        Version = "v1",
        Description = "Personal budgeting and cashflow management API"
    });
});

// Add database context
builder.Services.AddDbContext<BudgetBuddyDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
});

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

// Apply migrations and seed data in development
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<BudgetBuddyDbContext>();
    try
    {
        await db.Database.MigrateAsync();
        Log.Information("Database migrations applied successfully");
    }
    catch (Exception ex)
    {
        Log.Error(ex, "An error occurred while migrating the database");
    }
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "BudgetBuddy API v1");
    });
}

app.UseSerilogRequestLogging();

app.UseCors("AllowFrontend");

app.UseAuthorization();

app.MapControllers();

app.MapHealthChecks("/health");

app.MapGet("/", () => new
{
    name = "BudgetBuddy API",
    version = "v1",
    status = "running",
    documentation = "/swagger"
}).WithName("Root");

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
