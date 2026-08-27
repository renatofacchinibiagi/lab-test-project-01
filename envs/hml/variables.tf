variable "resource_group_name" {
	description = "Name of the homologation Resource Group."
	type        = string
}

variable "location" {
	description = "Azure region for homologation resources."
	type        = string
}

variable "virtual_network_name" {
	description = "Name of the homologation Virtual Network."
	type        = string
}

variable "virtual_network_address_space" {
	description = "CIDR ranges assigned to the homologation Virtual Network."
	type        = list(string)
}

variable "subnet_name" {
	description = "Name of the homologation subnet."
	type        = string
}

variable "subnet_address_prefixes" {
	description = "CIDR ranges assigned to the homologation subnet."
	type        = list(string)
}

variable "tags" {
	description = "Tags applied to supported homologation resources."
	type        = map(string)
}
