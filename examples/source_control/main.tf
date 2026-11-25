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

# This is the module call
module "automation_account" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.automation_account.name_unique
  parent_id = azapi_resource.resource_group.id
  sku = {
    name = "Basic"
  }
  automation_source_controls = {
    github-azureautomation-runbooks = {
      name                = "github-azureautomation-runbooks"
      folder_path         = "/Utility"
      repository_url      = "https://github.com/azureautomation/runbooks.git"
      source_control_type = "GitHub"
      branch              = "master"
      security = {
        token_type = "PersonalAccessToken"
        token      = var.security_token
      }
    }
  }
  enable_telemetry              = var.enable_telemetry
  public_network_access_enabled = false
}
