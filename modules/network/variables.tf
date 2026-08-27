variable "resource_group_name" {
  description = "Name of the Resource Group containing the network."
  type        = string
}

variable "location" {
  description = "Azure region for the network resources."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "virtual_network_address_space" {
  description = "CIDR ranges assigned to the Virtual Network."
  type        = list(string)
}

variable "subnet_name" {
  description = "Name of the subnet."
  type        = string
}

variable "subnet_address_prefixes" {
  description = "CIDR ranges assigned to the subnet."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to supported Azure resources."
  type        = map(string)
}