<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.00"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "null" {

}
provider "azurerm" {
  features {}
}


# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# provider "random" {}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "centralindia"
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_virtual_network" "this" {
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.this.location
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  address_prefixes     = ["192.168.1.0/24"]
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_network_interface" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-nic"
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "vm-example"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  admin_username                  = "testadmin"
  location                        = azurerm_resource_group.this.location
  name                            = "example-vm"
  network_interface_ids           = [azurerm_network_interface.this.id]
  resource_group_name             = azurerm_resource_group.this.name
  size                            = "Standard_B1s"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  identity {
    type = "SystemAssigned" #This is required for hybrid workers
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "this" {
  name                 = "HybridWorkerExtension"
  publisher            = "Microsoft.Azure.Automation.HybridWorker"
  type                 = "HybridWorkerForLinux"
  type_handler_version = "1.1"
  virtual_machine_id   = azurerm_linux_virtual_machine.this.id
  settings = jsonencode({
    AutomationAccountURL = module.azurerm_automation_account.hybrid_service_url
  })

  depends_on = [module.azurerm_automation_account]
}

# Add a null_resource to introduce a delay
resource "null_resource" "delay" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# This is the module call
module "azurerm_automation_account" {
  source                        = "../../"
  name                          = "example-account"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  sku                           = "Basic"
  public_network_access_enabled = false
  tags = {
    environment = "development"
  }

  automation_runbooks = {
    auto_runbook_key1 = {
      name         = "Get-AzureVMTutorial"
      description  = "This is an example runbook"
      script_path  = "runbook.ps1"
      log_verbose  = "true"
      log_progress = "true"
      runbook_type = "PowerShellWorkflow"
      publish_content_link = {
        uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
      }
    }
  }

  automation_hybrid_runbook_worker_groups = {
    auto_worker_group_key1 = {
      name = "example-worker-group"
    }
  }

  automation_hybrid_runbook_workers = {
    auto_worker_key1 = {
      hybrid_worker_group_key = "auto_worker_group_key1"
      vm_resource_id          = azurerm_linux_virtual_machine.this.id
    }
  }

  # the apply gets stuck at watcher deployment and fails with timeout. Need to verify what is wrong here
  automation_watchers = {
    auto_watcher_key1 = {
      name                           = "example-watcher"
      runbook_key                    = "auto_runbook_key1"
      hybrid_worker_group_key        = "auto_worker_group_key1"
      execution_frequency_in_seconds = 42
      description                    = "This is an example watcher"
      etag                           = "W/\"d1b3e3f2-1f2d-4b4d-8d0b-0b3b3b3b3b3b\""
      tags = {
        environment = "development"
      }
      script_parameters = {
        param1 = "value1"
        param2 = "value2"
      }
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.00)

- <a name="requirement_null"></a> [null](#requirement\_null) (3.2.3)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.00)

- <a name="provider_null"></a> [null](#provider\_null) (3.2.3)

## Resources

The following resources are used by this module:

- [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) (resource)
- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_machine_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [null_resource.delay](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_azurerm_automation_account"></a> [azurerm\_automation\_account](#module\_azurerm\_automation\_account)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->