namespace BudgetBuddy.Domain.Entities;

using BudgetBuddy.Domain.Common;

public class AuditEvent : BaseEntity
{
    public int AuditEventId { get; set; }
    public int UserId { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public string Action { get; set; } = string.Empty; // Create, Update, Delete
    public string? Changes { get; set; } // JSON
    public string? IpAddress { get; set; }
    public string? UserAgent { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public User User { get; set; } = null!;
}
