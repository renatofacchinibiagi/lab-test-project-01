output "virtual_network_id" {
	description = "Resource ID of the development Virtual Network."
	value       = module.network.virtual_network_id
}

output "subnet_id" {
	description = "Resource ID of the development subnet."
	value       = module.network.subnet_id
}
