variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus", "westus2", "centralus"], var.location)
    error_message = "Location must be one of: eastus, westus2, centralus"
  }
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "budgetbuddy"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "BudgetBuddy"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
  # In production, use Azure Key Vault or GitHub Secrets
}
