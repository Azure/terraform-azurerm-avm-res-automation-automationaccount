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

data "azurerm_client_config" "example" {}

# This is the module call
module "azurerm_automation_account" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.automation_account.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Basic"
  automation_connections = {
    auto_conn_key1 = {
      name        = "example-connection"
      description = "This is an example connection"
      type        = "AzureServicePrincipal"
      values = {
        "ApplicationId" : "00000000-0000-0000-0000-000000000000", # provide the appropriate value for "ApplicationId" to associate a Service principal with the Automation Account.
        "TenantId" : data.azurerm_client_config.example.tenant_id,
        "SubscriptionId" : data.azurerm_client_config.example.subscription_id,
        "CertificateThumbprint" : "sample-certificate-thumbprint",
      }
    }
  }
  automation_credentials = {
    auto_cred_key1 = {
      name        = "example-credential"
      description = "This is an example credential"
      username    = "admin"
      password    = "example_pwd"
    }
  }
  automation_modules = {
    auto_module_key1 = {
      name = "xActiveDirectory"
      module_link = {
        uri = "https://devopsgallerystorage.blob.core.windows.net/packages/xactivedirectory.2.19.0.nupkg"
      }
    }
  }
  automation_powershell72_modules = {
    auto_power72_key1 = {
      name = "ntfetch"
      module_link = {
        uri = "https://devopsgallerystorage.blob.core.windows.net/packages/ntfetch.0.50.0.nupkg"
      }
    }
  }
  automation_python3_packages = {
    auto_python3_key1 = {
      name            = "example2"
      content_uri     = "https://files.pythonhosted.org/packages/f9/9b/335f9764261e915ed497fcdeb11df5dfd6f7bf257d4a6a2a686d80da4d54/requests-2.32.3-py3-none-any.whl"
      content_version = "2.32.3"
      hash_algorithm  = "sha256"
      hash_value      = "70761cfe03c773ceb22aa2f671b4757976145175cdfca038c02654d061d6dcc6"
      tags = {
        environment = "development"
      }
    }
  }
  automation_schedules = {
    auto_schedule_key1 = {
      name        = "tfex-automation-schedule"
      description = "This is an example schedule"
      frequency   = "Week"
      interval    = 1
      #expiry_time = timeadd(timestamp, duration)
      timezone   = "Etc/UTC"
      start_time = "2027-04-15T18:00:15+02:00"
      week_days  = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    }
  }
  automation_variable_bools = {
    auto_var_bool_key1 = {
      name        = "example-bool-variable"
      description = "This is an example boolean variable"
      value       = true
    }
    auto_var_bool_key2 = {
      name        = "example-bool-variable2"
      description = "This is an example boolean variable"
      value       = false
    }
  }
  automation_variable_datetimes = {
    auto_var_dt_key1 = {
      name        = "example-datetime-variable"
      description = "This is an example datetime variable"
      value       = "2035-08-01T00:00:00Z"
    }
  }
  automation_variable_ints = {
    auto_var_int_key1 = {
      name        = "example-int-variable"
      description = "This is an example integer variable"
      value       = 42
    }
    auto_var_int_key2 = {
      name        = "example-int-variable2"
      description = "This is an example integer variable"
      value       = 36
    }
  }
  automation_variable_objects = {
    auto_var_obj_key1 = {
      name        = "example-object-variable"
      description = "This is an example object variable"
      value = jsonencode({
        greeting = "Hello, Terraform Basic Test."
        language = "en"
      })
    }
  }
  automation_variable_strings = {
    auto_var_string_key1 = {
      name        = "example-string-variable"
      description = "This is an example string variable"
      value       = "example-value"
    }
  }
  public_network_access_enabled = false
  tags = {
    environment = "development"
  }
}
