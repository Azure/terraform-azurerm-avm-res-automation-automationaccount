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

resource "azurerm_log_analytics_workspace" "workspace" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.eventhub_namespace.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  sku                      = "Standard"
  auto_inflate_enabled     = true
  capacity                 = 1
  maximum_throughput_units = 1
  tags = {
    environment = "avm-demo"
  }
}

resource "azurerm_eventhub" "eventhub" {
  message_retention = 1
  name              = "acceptanceTestEventHub"
  partition_count   = 2
  namespace_id      = azurerm_eventhub_namespace.eventhub_namespace.id
}

resource "azurerm_eventhub_namespace_authorization_rule" "example" {
  name                = "streamlogs"
  namespace_name      = azurerm_eventhub_namespace.eventhub_namespace.name
  resource_group_name = azurerm_resource_group.this.name
  listen              = true
  manage              = true
  send                = true
}

resource "azurerm_user_assigned_identity" "uami" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}


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
        "ApplicationId" : "00000000-0000-0000-0000-000000000000",
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
  diagnostic_settings = {
    workspace_diag = {
      name                  = "workspaceandstorage_diag"
      metric_categories     = ["AllMetrics"]
      log_categories        = ["JobLogs", "JobStreams", "AuditEvent"]
      log_groups            = [] # must explicitly set since log_groups defaults to ["allLogs"]
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
      #log_analytics_destination_type = "Dedicated"
      #marketplace_partner_resource_id          = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{partnerResourceProvider}/{partnerResourceType}/{partnerResourceName}"
    }
    eventhub_diag = {
      name                                     = "eventhubforwarding"
      log_groups                               = ["allLogs", "Audit"] # you can set either log_categories or log_groups.
      metric_categories                        = ["AllMetrics"]
      event_hub_authorization_rule_resource_id = azurerm_eventhub_namespace_authorization_rule.example.id
      event_hub_name                           = azurerm_eventhub_namespace.eventhub_namespace.name
    }
  }
  managed_identities = {
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }
  public_network_access_enabled = true
  role_assignments = {
    self_contributor = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = data.azurerm_client_config.example.object_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Reader"
      principal_id                     = data.azurerm_client_config.example.object_id # replace the principal id with appropriate one
      description                      = "Example role assignment 2 of reader role"
      skip_service_principal_aad_check = false
      principal_type                   = "ServicePrincipal"
      #condition                        = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase 'foo_storage_container'"
      #condition_version                = "2.0"
    }
  }
  # }
  tags = {
    environment = "development"
  }
}
