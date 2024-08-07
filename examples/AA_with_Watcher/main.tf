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

resource "azurerm_virtual_machine_extension" "this" {
  depends_on           = [module.azurerm_automation_account]
  name                 = "HybridWorkerExtension"
  virtual_machine_id   = azurerm_linux_virtual_machine.this.id
  publisher            = "Microsoft.Azure.Automation.HybridWorker"
  type                 = "HybridWorkerForLinux"
  type_handler_version = "1.1"

  settings = <<SETTINGS
    {
        "AutomationAccountURL" : "${module.azurerm_automation_account.hybrid_service_url}"
    }
SETTINGS
}

// Add a null_resource to introduce a delay
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  triggers = {
    always_run = "${timestamp()}"
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

  // the apply gets stuck at watcher deployment and fails with timeout. Need to verify what is wrong here
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
