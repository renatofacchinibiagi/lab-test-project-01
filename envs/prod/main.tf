module "network" {
	source = "../../modules/network"

	resource_group_name           = var.resource_group_name
	location                      = var.location
	virtual_network_name          = var.virtual_network_name
	virtual_network_address_space = var.virtual_network_address_space
	subnet_name                   = var.subnet_name
	subnet_address_prefixes       = var.subnet_address_prefixes
	tags                          = var.tags
}
