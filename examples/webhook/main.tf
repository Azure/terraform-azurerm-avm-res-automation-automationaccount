terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

# This is the module call
module "azurerm_automation_account" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.automation_account.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
  # Each Job_schedule must be associated with unique Schedule but can be associated with same Runbook.
  automation_job_schedules = {
    auto_job_schedule_key1 = {
      runbook_key  = "auto_runbook_key1"
      schedule_key = "auto_schedule_key1"
      parameters = {
        resourcegroup = "myResourceGroup"
        location      = "centralindia"
      }
    }
    auto_job_schedule_key2 = {
      runbook_key  = "auto_runbook_key1"
      schedule_key = "auto_schedule_key2"
      parameters = {
        resourcegroup = "myResourceGroup"
        vmname        = "TF-VM-01"
      }
    }
  }
  automation_runbooks = {
    auto_runbook_key1 = {
      name         = "Get-AzureVMTutorial"
      description  = "This is an example runbook"
      script_path  = "runbook.ps1"
      log_verbose  = "true"
      log_progress = "true"
      runbook_type = "PowerShell72"
      publish_content_link = {
        uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
      }
    }
  }
  automation_schedules = {
    auto_schedule_key1 = {
      name        = "TestRunbook_schedule"
      description = "This is an example schedule"
      start_time  = "2025-06-01T00:00:00Z"
      expiry_time = "2027-12-31T00:00:00Z"
      frequency   = "Month"
      interval    = 1
      time_zone   = "Etc/UTC"
      month_days  = [1, 15]
      monthly_occurrences = {
        day        = "Friday"
        occurrence = 1
      }
    }

    auto_schedule_key2 = {
      name        = "TestRunbook_schedule2"
      description = "This is an example2 schedule"
      start_time  = "2025-07-01T00:00:00Z"
      expiry_time = "2027-12-31T00:00:00Z"
      frequency   = "Week"
      interval    = 1
      time_zone   = "Asia/Tokyo"
      week_days   = ["Monday", "Wednesday", "Friday"]
    }
  }
  automation_webhooks = {
    auto_webhook_key1 = {
      name         = "TestRunbook_webhook"
      expiry_time  = "2027-12-31T00:00:00Z"
      enabled      = true
      runbook_name = "Get-AzureVMTutorial"
      parameters = {
        input = "parameter"
      }
    }
  }
  public_network_access_enabled = false
  tags = {
    environment = "development"
  }
}
