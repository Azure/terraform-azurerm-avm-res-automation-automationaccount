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

data "azurerm_client_config" "example" {}

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

  automation_webhooks = {
    auto_webhook_key1 = {
      name         = "TestRunbook_webhook"
      expiry_time  = "2024-12-31T00:00:00Z"
      enabled      = true
      runbook_name = "Get-AzureVMTutorial"
      parameters = {
        input = "parameter"
      }
    }
  }
}
