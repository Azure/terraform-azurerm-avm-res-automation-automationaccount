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
  admin_password        = random_password.password.result
  admin_username        = "testadmin"
  location              = azurerm_resource_group.this.location
  name                  = "example-vm"
  network_interface_ids = [azurerm_network_interface.this.id]
  resource_group_name   = azurerm_resource_group.this.name
  size                  = "Standard_B1s"

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

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azure-automation.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# This is the module call
module "azurerm_automation_account" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.automation_account.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
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
      # credential_name = "admin-password-credential"
    }
  }
  automation_hybrid_runbook_workers = {
    hybrid_worker_1_key = {
      hybrid_worker_group_key = "hybrid_worker_group_1_key"
      vm_resource_id          = azurerm_windows_virtual_machine.this.id
    }
  }
  private_endpoints = {
    pe-webhook = {
      # role_assignments   = {} # see interfaces/role assignments
      # lock               = {} # see interfaces/resource locks
      # tags               = {} # see interfaces/tags
      name                          = "pe-webhook"
      subnet_resource_id            = azurerm_subnet.this.id
      network_interface_name        = "nic1"
      subresource_name              = "Webhook"
      private_dns_zone_group_name   = "privatelink.azure-automation.net"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
    }
    pe-hybridworker = {
      name                          = "pe-hyrbidworker"
      subnet_resource_id            = azurerm_subnet.this.id
      network_interface_name        = "nic2"
      subresource_name              = "DSCAndHybridWorker"
      private_dns_zone_group_name   = "privatelink.azure-automation.net"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
    }
  }
  private_endpoints_manage_dns_zone_group = true
  public_network_access_enabled           = false
  tags = {
    environment = "development"
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
