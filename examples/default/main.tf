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
