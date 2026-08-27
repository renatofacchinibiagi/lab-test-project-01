terraform {
	backend "azurerm" {
		resource_group_name  = "lab-test-project-01"
		storage_account_name = "stlabtestproject01bdwkq4"
		container_name       = "tfstate"
		key                  = "hml.tfstate"
		use_azuread_auth     = true
	}
}
