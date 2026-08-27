output "resource_group_name" {
  description = "Resource Group containing the remote state backend."
  value       = azurerm_resource_group.bootstrap
}

output "storage_account_name" {
  description = "Storage Account name to use in each environment backend configuration."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Private blob container holding all environment states."
  value       = azurerm_storage_container.tfstate.name
}