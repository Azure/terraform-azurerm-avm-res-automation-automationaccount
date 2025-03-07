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
