## Requirements

- terraform
- ansible
- aws-cli

## Setting up a dev environment

1. Download prerequisites
2. `ansible-galaxy collection install ansible.posix community.docker` to install ansible requirements
2. `terraform init` to download terraform dependencies (e.g. `aws` module)
3. `aws configure` to login user to AWS
4. `terraform plan -var-file=dev.tfvars` to plan with correct dev env

## Generating entire infrastructure\:

- `terraform apply -var-file=dev.tfvars`
