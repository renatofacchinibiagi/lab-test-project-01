variable "resource_group_name" {
	description = "Name of the production Resource Group."
	type        = string
}

variable "location" {
	description = "Azure region for production resources."
	type        = string
}

variable "virtual_network_name" {
	description = "Name of the production Virtual Network."
	type        = string
}

variable "virtual_network_address_space" {
	description = "CIDR ranges assigned to the production Virtual Network."
	type        = list(string)
}

variable "subnet_name" {
	description = "Name of the production subnet."
	type        = string
}

variable "subnet_address_prefixes" {
	description = "CIDR ranges assigned to the production subnet."
	type        = list(string)
}

variable "tags" {
	description = "Tags applied to supported production resources."
	type        = map(string)
}
