# Avaliação Prática de DevOps — Cadastro de Cursos

## Integrantes
- Álvaro Nicolau Sebastião Gruli RA: 26001991
- Murilo Montoro Marqui RA: 26001976

## Objetivo
Implementar um sistema distribuído de cadastro de cursos
utilizando duas máquinas virtuais, infraestrutura como código,
automação de configuração e contêineres Docker.

## Tecnologias
- OpenTofu
- VirtualBox
- Ubuntu Server 24.04
- cloud-init
- Ansible
- Docker e Docker Compose
- Nginx
- HTML, CSS e JavaScript
- Node.js e Express
- MySQL 8.4

## Arquitetura

VM1 — Web:
- Nginx em contêiner Docker
- Interface de cadastro e listagem
- IP privado: 172.30.88.10
- Porta interna: 8080

VM2 — Backend:
- API Node.js em contêiner Docker
- MySQL em contêiner Docker
- Volume persistente mysql_data
- IP privado: 172.30.88.20
- Porta da API: 3000

A VM1 utiliza o Nginx como proxy reverso para acessar
a API da VM2 pela rede privada.

## Estrutura do projeto

- iac/main.tf: provisionamento das VMs
- iac/criar_vm.sh: comandos do VirtualBox
- iac/cloud_init.yaml: configuração inicial
- ansible/inventory: inventário das máquinas
- ansible/playbook.yml: implantação dos serviços
- ansible/rede.yml: configuração da rede privada
- app/: interface HTML e configuração do Nginx
- api/: API Node.js, MySQL e Docker Compose

## API REST

POST /curso — cadastra um curso.

Exemplo de JSON:
{
  "nome": "Introdução ao Python",
  "instrutor": "Professor Teste",
  "preco": 199.90,
  "vagas": 30
}

GET /cursos — lista os cursos cadastrados.

GET /health — verifica a conexão com o banco.

Pelo Nginx da VM1, as rotas utilizam o prefixo /api.

## Execução

Pré-requisitos:
- VirtualBox 7.1
- OpenTofu
- Ansible
- Ubuntu Server Cloud Image
- genisoimage
- SSH

1. Preparar uma imagem Ubuntu em formato VDI.
2. Criar as ISOs de cloud-init com user-data e meta-data.
3. Configurar a chave SSH pública no cloud-init.
4. Executar tofu init e tofu apply em iac/.
5. Inicializar as duas VMs no VirtualBox.
6. Configurar a rede privada pelo Ansible.
7. Criar api/.env com MYSQL_ROOT_PASSWORD,
   MYSQL_PASSWORD e CORS_ORIGIN.
8. Executar:
   ansible-playbook -i ansible/inventory ansible/playbook.yml
9. Acessar http://localhost:8181 no computador anfitrião.

Observação: ajustar os caminhos locais, portas e
configurações do VirtualBox conforme o ambiente.
O provisionamento utiliza terraform_data com
local-exec e não gerencia automaticamente a exclusão
das máquinas virtuais.

## Testes realizados

- Criação das duas VMs com OpenTofu.
- Inicialização das VMs com cloud-init.
- Conexão SSH e Ansible.
- Implantação da API e da interface via Docker.
- Comunicação direta entre VM1 e VM2.
- GET /health retornando HTTP 200.
- Cadastro e listagem de cursos.
- Persistência após reinício dos contêineres.

## Persistência

Os dados ficam no volume Docker mysql_data,
permitindo reiniciar os contêineres sem perder
os cursos cadastrados.

## Segurança

As senhas ficam em arquivos .env locais,
que não são publicados no repositório.
