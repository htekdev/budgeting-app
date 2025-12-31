using BudgetBuddy.Domain.Enums;

namespace BudgetBuddy.Domain.Entities;

public class AuditEvent : BaseEntity
{
    public int UserId { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public AuditAction Action { get; set; }
    public string? Changes { get; set; } // JSON format
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual User User { get; set; } = null!;
}
