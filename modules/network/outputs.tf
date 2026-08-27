output "resource_group_name" {
  description = "Name of the Resource Group created for the network."
  value       = azurerm_resource_group.network.name
}

output "virtual_network_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "Resource ID of the subnet."
  value       = azurerm_subnet.this.id
}