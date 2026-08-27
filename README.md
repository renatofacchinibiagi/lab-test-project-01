# lab-test-project-01

Laboratório de teste para praticar a criação e a organização de infraestrutura no Azure usando Terraform.

O projeto foi estruturado para ter três ambientes independentes:

- `dev`: desenvolvimento;
- `hml`: homologação, para validação antes de produção;
- `prod`: produção.

O objetivo é usar o mesmo código reutilizável nos três ambientes, mudando apenas os valores específicos de cada um.

## O que foi criado

Até este ponto, o projeto possui:

- um bootstrap para criar a estrutura compartilhada do Terraform;
- uma Storage Account para armazenar os estados remotos;
- um container privado de Blob Storage chamado `tfstate`;
- um state separado para cada ambiente;
- um módulo de rede reutilizável;
- uma Resource Group, uma Virtual Network e uma subnet para cada ambiente.

## Estrutura do projeto

```text
lab-test-project-01/
|
|-- bootstrap/
|   |-- main.tf
|   |-- variables.tf
|   |-- outputs.tf
|   |-- versions.tf
|   |-- terraform.tfvars.example
|   `-- README.md
|
|-- modules/
|   |-- network/
|       |-- main.tf
|       |-- variables.tf
|       `-- outputs.tf
|
`-- envs/
		|-- dev/
		|   |-- backend.tf
		|   |-- providers.tf
		|   |-- main.tf
		|   |-- variables.tf
		|   |-- terraform.tfvars
		|   `-- outputs.tf
		|-- hml/
		|   `-- mesmos arquivos do dev
		`-- prod/
				`-- mesmos arquivos do dev
```

## Conceitos principais

### Terraform

Terraform é uma ferramenta de Infraestrutura como Código, também chamada de IaC. Em vez de criar recursos manualmente pelo portal Azure, descrevemos o resultado desejado em arquivos de configuração.

O Terraform compara o código, o estado salvo e os recursos existentes no Azure. Com essa comparação, ele sabe o que precisa criar, alterar ou remover.

### Provider

O provider é o componente que permite ao Terraform conversar com um serviço. Neste projeto usamos o provider `azurerm`, responsável pelos recursos do Azure.

O provider é configurado em `providers.tf`:

```hcl
terraform {
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~> 4.0"
		}
	}
}

provider "azurerm" {
	features {}
}
```

### Variáveis

As variáveis se dividem em três partes:

- `variables.tf` declara o nome, o tipo e a descrição;
- `terraform.tfvars` informa os valores de um ambiente;
- `main.tf` usa esses valores ou os repassa para um módulo.

Exemplo:

```hcl
# variables.tf
variable "virtual_network_name" {
	type = string
}
```

```hcl
# terraform.tfvars
virtual_network_name = "vnet-lab-test-project-01-dev"
```

```hcl
# main.tf
virtual_network_name = var.virtual_network_name
```

Assim, o módulo continua genérico e cada ambiente escolhe seus próprios nomes e CIDRs.

### Módulo

Um módulo é um conjunto reutilizável de configurações Terraform. O módulo `modules/network` contém a lógica para criar:

- Resource Group da rede;
- Virtual Network;
- subnet.

O ambiente chama o módulo em seu `main.tf`:

```hcl
module "network" {
	source = "../../modules/network"
}
```

O código da rede é escrito uma vez e utilizado em `dev`, `hml` e `prod`.

## Bootstrap

O diretório `bootstrap` é executado primeiro e raramente depois disso. Ele cria a base necessária para guardar os states remotos:

```text
Resource Group:  lab-test-project-01
Storage Account: stlabtestproject01bdwkq4
Container:       tfstate
```

A Storage Account foi configurada com algumas proteções. O objetivo é proteger o `tfstate`, que pode conter nomes, IDs, configurações e outros detalhes importantes da infraestrutura.

### Somente tráfego HTTPS

```hcl
https_traffic_only_enabled = true
```

Faz com que a comunicação com a Storage Account use HTTPS. O conteúdo trafega criptografado entre o Terraform e o Azure, reduzindo o risco de alguém interceptar os dados durante a comunicação.

### TLS mínimo 1.2

```hcl
min_tls_version = "TLS1_2"
```

TLS é o protocolo de segurança usado pelo HTTPS. Esta configuração bloqueia clientes que tentem usar versões antigas e mais vulneráveis do protocolo. O computador ou pipeline que executar o Terraform precisa ser compatível com TLS 1.2 ou superior.

### Acesso público a blobs desabilitado

```hcl
allow_nested_items_to_be_public = false
```

Um blob é um arquivo armazenado no Azure Blob Storage. Esta configuração impede que containers ou blobs sejam publicados para acesso anônimo pela internet. Para ler ou alterar o state, a pessoa ou pipeline ainda precisa se autenticar e ter permissão.

### Autenticação por Access Key desabilitada

```hcl
shared_access_key_enabled = false
```

Uma Access Key funciona como uma senha de alto privilégio para a Storage Account. Se ela for exposta, pode permitir acesso amplo aos dados. Por isso, o projeto não utiliza chaves fixas e exige autenticação por identidade do Microsoft Entra ID.

### Microsoft Entra ID e RBAC

O provider AzureRM está configurado para usar Entra ID nas operações de Blob Storage:

```hcl
storage_use_azuread = true
```

RBAC significa controle de acesso baseado em função. No bootstrap, a identidade que executou o Terraform recebe a função `Storage Blob Data Contributor` na Storage Account. Essa função permite ler, criar, atualizar e remover blobs, que são as operações necessárias para trabalhar com o state.

A permissão é aplicada no escopo da Storage Account, em vez de ser concedida para toda a assinatura. Em um cliente, o ideal é substituir acessos pessoais por identidades de pipeline e reduzir ainda mais o escopo, por exemplo, uma identidade diferente para cada ambiente.

### Container privado

```hcl
container_access_type = "private"
```

O container `tfstate` não permite acesso anônimo. Mesmo que alguém descubra o endereço do blob, não conseguirá ler o arquivo sem autenticação e autorização no Azure.

### Como as proteções trabalham juntas

```text
Terraform
	|
	| HTTPS + TLS 1.2
	v
Storage Account
	|
	| Microsoft Entra ID + RBAC
	v
Container privado tfstate
	|
	+-- dev.tfstate
	+-- hml.tfstate
	`-- prod.tfstate
```

HTTPS e TLS protegem o caminho da comunicação. Entra ID e RBAC identificam quem está acessando. O container privado e o bloqueio de acesso público impedem acesso anônimo. A desativação de Access Keys elimina uma forma de autenticação baseada em segredo estático.

Estas configurações protegem o acesso, mas não substituem boas práticas operacionais: o state continua sendo sensível, deve ter permissões mínimas e não deve ser enviado para o Git.

Para produção, uma evolução possível é desabilitar também o acesso público à rede da Storage Account e usar um Private Endpoint. Nesse modelo, os agentes de CI/CD precisam executar em uma rede autorizada a alcançar o endpoint privado.

O bootstrap utiliza state local porque ele cria o próprio backend remoto. Os ambientes de aplicação utilizam o backend Azure criado pelo bootstrap.

Para executar o bootstrap:

```powershell
cd .\bootstrap
terraform init
terraform validate
terraform plan
terraform apply
```

O `plan` apenas mostra o que será feito. O `apply` cria ou altera os recursos no Azure.

## State remoto

O arquivo `.tfstate` é o registro que o Terraform usa para saber quais recursos estão sob seu gerenciamento. Ele não deve ser versionado no Git nem criado manualmente.

Os ambientes compartilham a Storage Account e o container, mas cada um usa uma chave diferente:

```text
tfstate/
|-- dev.tfstate
|-- hml.tfstate
`-- prod.tfstate
```

Essa separação impede que o Terraform de `dev` misture seus recursos com os de `hml` ou `prod`.

Os backends ficam nestes arquivos:

```text
envs/dev/backend.tf  -> key = "dev.tfstate"
envs/hml/backend.tf  -> key = "hml.tfstate"
envs/prod/backend.tf -> key = "prod.tfstate"
```

O comando `terraform init` em cada ambiente configura essa conexão. O `-reconfigure` só é necessário quando a configuração do backend muda ou quando o Terraform pede uma reconfiguração.

## Rede criada por ambiente

Cada ambiente recebe uma rede isolada e com endereçamento diferente:

| Ambiente | Resource Group | VNet CIDR | Subnet CIDR |
|---|---|---|---|
| `dev` | `rg-lab-test-project-01-dev` | `10.10.0.0/16` | `10.10.1.0/24` |
| `hml` | `rg-lab-test-project-01-hml` | `10.20.0.0/16` | `10.20.1.0/24` |
| `prod` | `rg-lab-test-project-01-prod` | `10.30.0.0/16` | `10.30.1.0/24` |

Os CIDRs são faixas de endereços IP. Uma VNet recebe a faixa maior e a subnet ocupa uma faixa menor dentro dela.

Por exemplo, em `dev`:

```text
VNet:    10.10.0.0/16
Subnet:  10.10.1.0/24
```

Os valores ficam nos arquivos `terraform.tfvars` de cada ambiente. Para redes que precisarão se conectar no futuro, os CIDRs devem ser planejados para não entrar em conflito com outras redes corporativas.

## Fluxo de trabalho

Para qualquer ambiente, a sequência normal é:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

### `terraform init`

Prepara o diretório, baixa os providers, carrega módulos e configura o backend remoto.

### `terraform validate`

Verifica se a configuração está sintaticamente correta e se os argumentos necessários estão presentes. Não acessa nem altera recursos do Azure.

### `terraform plan`

Mostra as mudanças que o Terraform pretende fazer. É a etapa de revisão antes da alteração real.

### `terraform apply`

Executa as mudanças aprovadas e atualiza o state remoto ao final.

## Situação atual

O bootstrap foi aplicado com sucesso e as redes de `dev`, `hml` e `prod` também foram criadas com sucesso. Os três ambientes têm backend remoto configurado e cada um mantém seu state separado no Azure Blob Storage.

States criados no Azure:

```text
dev.tfstate  -> após o apply de dev
hml.tfstate  -> após o apply de hml
prod.tfstate -> após o apply de prod
```

## Próximos passos

Com os três ambientes aplicados, o fluxo recomendado agora é:

1. Executar `terraform plan` novamente em cada ambiente e confirmar que não há mudanças inesperadas.
2. Conferir no Azure as VNets, subnets e Resource Groups criados.
3. Adicionar novos módulos, como compute, storage da aplicação, banco de dados e monitoramento.
4. Definir regras de acesso por ambiente, especialmente para `prod`.
5. Criar um pipeline CI/CD para validar e aplicar as mudanças sem depender de execução manual.

## Boas práticas importantes

- Não colocar senhas, tokens, chaves ou secrets no Git.
- Não versionar arquivos `.tfstate`, `.terraform` ou `terraform.tfvars` reais.
- Usar Pull Requests e revisão antes de alterar `prod`.
- Executar `plan` antes de todo `apply`.
- Usar identidades de pipeline e permissões RBAC com o menor escopo possível.
- Manter CIDRs diferentes entre os ambientes.
- Não alterar manualmente no portal recursos gerenciados pelo Terraform, salvo em situações controladas.
- Fazer backup, versionamento e retenção do state conforme a política do cliente.





