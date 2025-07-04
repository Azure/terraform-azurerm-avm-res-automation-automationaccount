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
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
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
  # Uncheck the following line of code to use the Stand-alone azurerm_automation_job_schedule module. In such case ensure that you uncheck/remove the code for the inlined 'job_schedule' [Line 63-78] because at this time you can choose only one of them to manage job schedule resources. Refer https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule
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
      description  = "This is an example runbook"
      script_path  = "runbook.ps1"
      log_verbose  = "true"
      log_progress = "true"
      runbook_type = "PowerShell72"
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
      start_time  = "2026-06-01T00:00:00Z"
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
      start_time  = "2026-07-01T00:00:00Z"
      expiry_time = "2027-12-31T00:00:00Z"
      frequency   = "Week"
      interval    = 1
      time_zone   = "Asia/Tokyo"
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
  public_network_access_enabled = false
  tags = {
    environment = "development"
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)

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