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

  automation_credentials = {
    auto_cred_key1 = {
      name        = "example-credential"
      description = "This is an example credential"
      username    = "admin"
      password    = "example_pwd"
    }
  }

  // usimg self-signed certificate for testing, exmple is failing with "invalid base64"
  # automation_certificates = {
  #   auto_cert_key1 = {
  #     name        = "example-certificate"
  #     description = "This is an example certificate"
  #     base64      = filebase64("certificate.pfx")
  #     exportable  = true
  #   }
  # }
  automation_connections = {
    auto_conn_key1 = {
      name        = "example-connection"
      description = "This is an example connection"
      type        = "AzureServicePrincipal"
      values = {
        "ApplicationId" : "3ff01f1c-3fd0-4875-bb11-b3beb05fe07e", #"00000000-0000-0000-0000-000000000000",
        "TenantId" : data.azurerm_client_config.example.tenant_id,
        "SubscriptionId" : data.azurerm_client_config.example.subscription_id,
        "CertificateThumbprint" : "sample-certificate-thumbprint",
      }
    }
  }

  // the below block doesnt seem to work
  # automation_connection_certificates = {
  #   auto_conn_cert_key1 = {
  #     automation_certificate_name = "example-certificate"
  #     subscription_id = data.azurerm_client_config.example.subscription_id
  #   }
  # }

  automation_schedules = {
    auto_schedule_key1 = {
      name        = "tfex-automation-schedule"
      description = "This is an example schedule"
      frequency   = "Week"
      interval    = 1
      expiry_time = "2024-12-31T00:00:00Z"
      timezone    = "Etc/UTC"
      start_time  = "2024-08-01T00:00:00Z"
      week_days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    }
  }

  // All modules are automatically getting loaded. How to test the below example block?
  # automation_modules = {
  #   auto_module_key1 = {
  #     name        = "xActiveDirectory"
  #     module_link = {
  #       uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/automation-dsc-extension-configure-push-pull-mode/azuredeploy.json"
  #     }
  #   }
  # }
  # automation_powershell72_modules = {
  #   auto_power72_key1 = {
  #     name        = "Az.Accounts"
  #     module_link = {
  #       uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.2.1"
  #     }
  #   }
  # }

  //Need to verify how to get python packages with .whl extension as .tar is not supported.
  # automation_python3_packages = {
  #   auto_python3_key1 = {
  #     name          = "example2"
  #     content_uri   = "https://pypi.org/packages/source/r/requests/requests-2.31.0.tar.whl"
  #     content_version = "2.31.0"
  #     hash_algorithm = "sha256"
  #     hash_value     = "942c5a758f98d790eaed1a29cb6eefc7ffb0d1cf7af05c3d2791656dbd6ad1e1"
  #     tags = {
  #       environment = "development"
  #     }
  #   }
  # }

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
      value       = "2024-08-01T00:00:00Z"
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
}
