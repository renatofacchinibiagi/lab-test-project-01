variable "resource_group_name" {
  description = "Name of the Resource Group that stores Terraform remote state."
  type        = string
  default     = "lab-test-project-01"
}

variable "location" {
  description = "Azure region for the bootstrap resources."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags applied to all supported bootstrap resources."
  type        = map(string)

  default = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "lab-test-project-01"
  }
}