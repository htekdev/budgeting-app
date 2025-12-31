namespace BudgetBuddy.Domain.Enums;

public enum AccountType
{
    Checking,
    Savings,
    Credit,
    Investment,
    Cash
}

public enum TransactionType
{
    Income,
    Expense,
    Transfer
}

public enum CategoryType
{
    Income,
    Expense
}

public enum RecurrenceFrequency
{
    Daily,
    Weekly,
    BiWeekly,
    Monthly,
    Quarterly,
    Yearly
}

public enum AuditAction
{
    Create,
    Update,
    Delete
}
