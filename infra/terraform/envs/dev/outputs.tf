output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.data.sql_server_fqdn
}

output "api_url" {
  description = "URL of the API endpoint"
  value       = module.app.api_url
}

output "frontend_url" {
  description = "URL of the frontend"
  value       = module.app.frontend_url
}
