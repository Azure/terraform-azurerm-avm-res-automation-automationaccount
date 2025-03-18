<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

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
  name                = module.naming.automation_account.name_unique
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
        "ApplicationId" : "00000000-0000-0000-0000-000000000000",
        "TenantId" : data.azurerm_client_config.example.tenant_id,
        "SubscriptionId" : data.azurerm_client_config.example.subscription_id,
        "CertificateThumbprint" : "sample-certificate-thumbprint",
      }
    }
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