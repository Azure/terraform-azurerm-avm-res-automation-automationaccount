terraform {
  required_version = ">= 1.11, < 2.0"

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

data "azapi_client_config" "current" {}

# This is the module call
module "automation_account" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.automation_account.name_unique
  parent_id = azapi_resource.resource_group.id
  sku = {
    name = "Basic"
  }
  automation_connections = {
    auto_conn_key1 = {
      name        = "example-connection"
      description = "This is an example connection"
      type        = "AzureServicePrincipal"
      values = {
        "ApplicationId" : "00000000-0000-0000-0000-000000000000",
        "TenantId" : data.azapi_client_config.current.tenant_id,
        "SubscriptionId" : data.azapi_client_config.current.subscription_id,
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
  enable_telemetry              = var.enable_telemetry
  public_network_access_enabled = true
  tags = {
    environment = "development"
  }
}
