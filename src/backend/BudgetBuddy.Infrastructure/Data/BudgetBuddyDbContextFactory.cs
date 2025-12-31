using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace BudgetBuddy.Infrastructure.Data;

public class BudgetBuddyDbContextFactory : IDesignTimeDbContextFactory<BudgetBuddyDbContext>
{
    public BudgetBuddyDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<BudgetBuddyDbContext>();
        optionsBuilder.UseSqlServer("Server=localhost;Database=BudgetBuddy;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;");

        return new BudgetBuddyDbContext(optionsBuilder.Options);
    }
}
