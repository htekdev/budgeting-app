# Database Migration Skill

Creates and manages Entity Framework Core database migrations.

## Usage
When you need to:
- Add a new table
- Modify existing schema
- Seed data
- Update relationships

## Steps

1. **Update DbContext or Models**
   Make your schema changes in the model classes or DbContext configuration.

2. **Create Migration**
   ```bash
   cd backend/BudgetBuddy.Api
   dotnet ef migrations add <MigrationName>
   ```

3. **Review Migration**
   Check the generated migration file in `Migrations/` folder to ensure it's correct.

4. **Apply Migration**
   ```bash
   dotnet ef database update
   ```

5. **For Production**
   Generate SQL script for review:
   ```bash
   dotnet ef migrations script
   ```

## Migration Naming
Use descriptive names:
- `AddUserTable`
- `AddBudgetCategoryRelationship`
- `SeedInitialData`
- `UpdateTransactionAmountPrecision`

## Best Practices
- Always review generated migrations
- Test migrations on a copy of production data
- Make migrations reversible when possible
- Keep migrations small and focused
- Never edit applied migrations
- Include data migrations when needed

## Rollback
```bash
dotnet ef database update <PreviousMigrationName>
dotnet ef migrations remove
```
