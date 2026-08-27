variable "resource_group_name" {
	description = "Name of the development Resource Group."
	type        = string
}

variable "location" {
	description = "Azure region for development resources."
	type        = string
}

variable "virtual_network_name" {
	description = "Name of the development Virtual Network."
	type        = string
}

variable "virtual_network_address_space" {
	description = "CIDR ranges assigned to the development Virtual Network."
	type        = list(string)
}

variable "subnet_name" {
	description = "Name of the development subnet."
	type        = string
}

variable "subnet_address_prefixes" {
	description = "CIDR ranges assigned to the development subnet."
	type        = list(string)
}

variable "tags" {
	description = "Tags applied to supported development resources."
	type        = map(string)
}
