## Requirements

- terraform
- ansible
- aws-cli

## Setting up a dev environment

1. Download prerequisites
2. `ansible-galaxy collection install ansible.posix` to install ansible requirements
2. `terraform init` to download terraform dependencies (e.g. `aws` module)
3. `aws configure` to login user to AWS
4. `terraform plan -var-file=dev.tfvars` to plan with correct dev env

## Generating entire infrastructure\:

- `terraform apply -var-file=dev.tfvars`

## Adding a new device to telegraf

### Configuring Telegraf

Each collection of devices, e.g. those monitoring a single water treatment plant or in a single DMA, are grouped into a collection of devices all outputting data to a single bucket. The config data is stored as a JSON file and is turned into part of the Telegraf config by ansible. FYI Telegraf is the service used to query modbus devices (among many types of devices) and send that data to the database.

To tell Telegraf about a new device:

1. Create a new file in `ansible/configuration/telegraf/device_data` corresponding to the new group of devices OR add a new device to an existing config.
2. Most config parameters are straight forward but you must include the parameters set in the moni:tool modbus interface **in exact* order**.
4. Add the name of the config to `ansible/setup-ingestion.yml`
5. Manually run the ansible playbook
