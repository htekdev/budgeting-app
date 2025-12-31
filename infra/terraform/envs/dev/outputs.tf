output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Add more outputs as modules are added
# output "app_url" {
#   description = "URL of the deployed application"
#   value       = module.app.app_url
# }

# output "sql_server_fqdn" {
#   description = "Fully qualified domain name of SQL Server"
#   value       = module.data.sql_server_fqdn
#   sensitive   = false
# }
