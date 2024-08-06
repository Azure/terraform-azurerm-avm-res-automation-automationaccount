terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "centralindia"
}

resource "azurerm_virtual_network" "this" {
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.this.location
}

resource "azurerm_subnet" "this" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "example-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "vm-example"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "example-vm"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  size                            = "Standard_B1s"
  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned" // This is required for hybrid workers
  }

  network_interface_ids = [azurerm_network_interface.this.id]
}

# This is the module call
module "azurerm_automation_account" {
  source              = "../../"
  name                = "example-account"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
  tags = {
    environment = "development"
  }

// Need to add a timer here as automation account is unable to find the credential in first try
  automation_credentials = {
    auto_cred_key1 = {
      name        = "example-credential"
      description = "This is an example credential"
      username    = "admin"
      password    = "example_pwd"
    }
  }

  automation_hybrid_runbook_worker_groups = {
    auto_worker_group_key1 = {
      name            = "example-worker-group"
      credential_name = "example-credential"
    }
  }

// how to add an existing VM as a hybrid worker ? tried but getting errors
  automation_hybrid_runbook_workers = {
    auto_worker_key1 = {
        hybrid_worker_group_key = "auto_worker_group_key1"
        vm_resource_id = azurerm_linux_virtual_machine.this.id
    }
  }
}
