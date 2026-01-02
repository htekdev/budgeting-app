variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1" # Basic tier
}

variable "sql_database_sku" {
  description = "SQL Database SKU"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Application = "BudgetBuddy"
    ManagedBy   = "Terraform"
  }
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access SQL Server"
  type        = list(string)
  default     = []
}
