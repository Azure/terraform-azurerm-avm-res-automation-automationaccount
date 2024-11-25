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

  # using self-signed certificate for testing, exmple is failing with "invalid base64"
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

  # the below block doesnt seem to work
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

  # All modules are automatically getting loaded. How to test the below example block?
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

  # Need to verify how to get python packages with .whl extension as .tar is not supported.
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_client_config.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

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