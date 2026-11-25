terraform {
  required_version = ">= 1.11, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
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

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "0.2.0"
}

# This is required for resource modules
resource "azapi_resource" "resource_group" {
  location = "centralindia"
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
}

resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = "example-vnet"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2026-03-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.1.0/24"]
      }
    }
  }
}

resource "azapi_resource" "subnet" {
  name      = "example-subnet"
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2026-03-01"
  body = {
    properties = {
      addressPrefix         = "192.168.1.0/24"
      defaultOutboundAccess = true
    }
  }
}

resource "azapi_resource" "network_interface" {
  location  = azapi_resource.resource_group.location
  name      = "example-nic"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkInterfaces@2026-03-01"
  body = {
    properties = {
      ipConfigurations = [
        {
          name = "testconfiguration1"
          properties = {
            primary                   = true
            privateIPAddressVersion   = "IPv4"
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = azapi_resource.subnet.id
            }
          }
        }
      ]
    }
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

resource "azapi_resource" "virtual_machine" {
  location  = azapi_resource.resource_group.location
  name      = "example-vm"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Compute/virtualMachines@2023-03-01"
  body = {
    zones = ["1"]
    properties = {
      hardwareProfile = {
        vmSize = "Standard_B1s"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.network_interface.id
          }
        ]
      }
      osProfile = {
        computerName  = "example-vm"
        adminUsername = "testadmin"
      }
      storageProfile = {
        osDisk = {
          caching      = "ReadWrite"
          createOption = "FromImage"
          name         = "osdisk"
          managedDisk = {
            storageAccountType = "Premium_LRS"
          }
        }
        imageReference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2016-Datacenter"
          version   = "latest"
        }
      }
    }
  }
  sensitive_body = {
    properties = {
      osProfile = {
        adminPassword = random_password.password.result
      }
    }
  }
  sensitive_body_version = {
    "properties.osProfile.adminPassword" = "1"
  }

  identity {
    type = "SystemAssigned"
  }
}

# This is the module call
module "automation_account" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.automation_account.name_unique
  parent_id = azapi_resource.resource_group.id
  sku = {
    name = "Basic"
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
      name            = "hybrid_worker_group_1"
      credential_name = "admin-password-credential"
    }
  }
  automation_hybrid_runbook_workers = {
    hybrid_worker_1_key = {
      hybrid_worker_group_key = "hybrid_worker_group_1_key"
      vm_resource_id          = azapi_resource.virtual_machine.id
    }
  }
  enable_telemetry              = var.enable_telemetry
  public_network_access_enabled = true
  tags = {
    environment = "development"
  }
}

resource "azapi_resource" "hybrid_worker_extension" {
  location  = azapi_resource.virtual_machine.location
  name      = "${azapi_resource.virtual_machine.name}HybridWorkerExtension"
  parent_id = azapi_resource.virtual_machine.id
  type      = "Microsoft.Compute/virtualMachines/extensions@2026-04-01"
  body = {
    properties = {
      autoUpgradeMinorVersion = true
      publisher               = "Microsoft.Azure.Automation.HybridWorker"
      settings = {
        AutomationAccountURL = module.automation_account.hybrid_service_url
      }
      type               = "HybridWorkerForwindows"
      typeHandlerVersion = "1.1"
    }
  }
  response_export_values = []
  retry = {
    error_message_regex = ["HybridRunbookWorkerGroupNotFound", "AutomationAccountNotFound"]
  }

  depends_on = [azapi_resource.virtual_machine, module.automation_account]
}
