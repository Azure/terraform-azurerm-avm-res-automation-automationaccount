terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
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

# This is the module call
module "automation_account" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.automation_account.name_unique
  parent_id = azapi_resource.resource_group.id
  sku = {
    name = "Basic"
  }
  # automation_job_schedules = {
  #   auto_job_schedule_key1 = {
  #     runbook_key  = "auto_runbook_key1" # Each Job_schedule must be associated with unique Schedule but can be associated with same Runbook.
  #     schedule_key = "auto_schedule_key1"
  #     parameters = {
  #       resourcegroup = "myResourceGroup"
  #       location      = "centralindia"
  #     }
  #   }
  #   auto_job_schedule_key2 = {
  #     runbook_key  = "auto_runbook_key1"
  #     schedule_key = "auto_schedule_key2"
  #     parameters = {
  #       resourcegroup = "myResourceGroup"
  #       vmname        = "TF-VM-01"
  #     }
  #   }
  # }
  automation_runbooks = {
    auto_runbook_key1 = {
      name         = "Get-AzureVMTutorial"
      runbook_type = "PowerShell72"
      log_verbose  = true
      log_progress = true
      description  = "This is an example runbook"
      job_schedule = [
        {
          parameters = {
            resourcegroup = "myResourceGroup"
            location      = "centralindia"
          }
          schedule_key = "auto_schedule_key1"
        },
        {
          parameters = {
            resourcegroup = "myResourceGroup"
            vmname        = "TF-VM-01"
          }
          schedule_key = "auto_schedule_key2"
        }
      ]
      publish_content_link = {
        uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
      }
    }
  }
  automation_schedules = {
    auto_schedule_key1 = {
      name        = "TestRunbook_schedule"
      description = "This is an example schedule"
      start_time  = "2026-12-01T00:00:00Z"
      expiry_time = "2027-12-31T00:00:00Z"
      frequency   = "Month"
      interval    = 1
      timezone    = "Etc/UTC"
      month_days  = [1, 15]
      monthly_occurrence = {
        day        = "Friday"
        occurrence = 1
      }
    }

    auto_schedule_key2 = {
      name        = "TestRunbook_schedule2"
      description = "This is an example2 schedule"
      start_time  = "2027-01-01T00:00:00Z"
      expiry_time = "2027-12-31T00:00:00Z"
      frequency   = "Week"
      interval    = 1
      timezone    = "Asia/Tokyo"
      week_days   = ["Monday", "Wednesday", "Friday"]
    }
  }
  automation_webhooks = {
    auto_webhook_key1 = {
      name        = "TestRunbook_webhook"
      expiry_time = "2027-12-31T00:00:00Z"
      enabled     = true
      runbook_key = "auto_runbook_key1"
      parameters = {
        input = "parameter"
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  public_network_access_enabled = false
  tags = {
    environment = "development"
  }
}
