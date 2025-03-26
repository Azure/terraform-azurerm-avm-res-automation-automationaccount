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
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "38482de8-520d-482d-b905-09bdedcb4ad6"
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

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
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "random_password" "password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

resource "azurerm_windows_virtual_machine" "this" {
  admin_password                    = random_password.password.result
  admin_username                    = "testadmin"
  location                          = azurerm_resource_group.this.location
  name                              = "example-vm"
  network_interface_ids             = [azurerm_network_interface.this.id]
  resource_group_name               = azurerm_resource_group.this.name
  size                              = "Standard_B1s"
  vm_agent_platform_updates_enabled = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  identity {
    type = "SystemAssigned" # This is required for hybrid workers
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# This is the module call
module "azurerm_automation_account" {
  source                        = "../../"
  name                          = module.naming.automation_account.name_unique
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  sku                           = "Basic"
  public_network_access_enabled = true
  tags = {
    environment = "development"
  }

  automation_credentials = {
    cred_1_key = {
      name        = "admin-password-credential"
      description = "Admin password credential object"
      username    = "admin"
      password    = "example_pwd"
      timeouts = {
        read   = "2m"
        create = "2m"
        update = "2m"
        delete = "2m"
      }
    }
  }

  automation_hybrid_runbook_worker_groups = {
    hybrid_worker_group_1_key = {
      name = "hybrid_worker_group_1"
      #credential_name = "admin-password-credential"
    }
  }

  automation_hybrid_runbook_workers = {
    hybrid_worker_1_key = {
      hybrid_worker_group_key = "hybrid_worker_group_1_key"
      vm_resource_id          = azurerm_windows_virtual_machine.this.id
    }
  }

}

resource "azurerm_virtual_machine_extension" "hybrid_worker_extension" {
  name                       = "${azurerm_windows_virtual_machine.this.name}HybridWorkerExtension"
  publisher                  = "Microsoft.Azure.Automation.HybridWorker"
  type                       = "HybridWorkerForwindows"
  type_handler_version       = "1.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "AutomationAccountURL": "${module.azurerm_automation_account.hybrid_service_url}"
    }
  SETTINGS

  depends_on = [azurerm_windows_virtual_machine.this, module.azurerm_automation_account]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.7.1)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (>= 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_machine_extension.hybrid_worker_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.7.1/docs/resources/password) (resource)
- [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)

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