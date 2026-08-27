output "virtual_network_id" {
	description = "Resource ID of the homologation Virtual Network."
	value       = module.network.virtual_network_id
}

output "subnet_id" {
	description = "Resource ID of the homologation subnet."
	value       = module.network.subnet_id
}
