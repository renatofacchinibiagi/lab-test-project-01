# Bootstrap do Terraform State

Este diretório cria uma única base compartilhada para os estados remotos:

- Resource Group: `lab-test-project-01`
- Storage Account: nome único gerado com o prefixo `stlabtestproject01`
- Container privado: `tfstate`

O bootstrap inicia com state local porque o backend remoto ainda não existe. Execute-o autenticado no Azure com uma identidade que possa criar recursos e atribuições RBAC:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

Após o apply, obtenha o nome da Storage Account:

```powershell
terraform output -raw storage_account_name
```

Em cada `envs/<ambiente>/backend.tf`, use o mesmo Resource Group, Storage Account e container; altere somente `key`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "lab-test-project-01"
    storage_account_name = "<nome-exibido-pelo-output>"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
    use_azuread_auth     = true
  }
}
```

Para `hml` e `prod`, utilize respectivamente `hml.tfstate` e `prod.tfstate`. A identidade que executar Terraform nesses ambientes precisa da função `Storage Blob Data Contributor` na Storage Account.