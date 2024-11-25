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

  automation_source_controls = {
    auto_source-control_key1 = {
      name                = "example-source-control"
      description         = "This is an example source control"
      source_control_type = "GitHub"
      folder_path         = "/"
      repository_url      = "https://github.com/ABCD/XYZ.git"
      branch              = "dev"

      security = {
        token_type = "PersonalAccessToken"
        token      = "ghp_xxxxxx"
      }
    }
  }
}