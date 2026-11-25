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

resource "azapi_resource" "workspace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.log_analytics_workspace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2022-10-01"
}

resource "azapi_resource" "eventhub_namespace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.eventhub_namespace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.EventHub/namespaces@2024-01-01"
  body = {
    properties = {
      isAutoInflateEnabled   = true
      maximumThroughputUnits = 1
      minimumTlsVersion      = "1.2"
      zoneRedundant          = true
    }
    sku = {
      capacity = 1
      name     = "Standard"
      tier     = "Standard"
    }
  }
}

resource "azapi_resource" "eventhub" {
  name      = "acceptanceTestEventHub"
  parent_id = azapi_resource.eventhub_namespace.id
  type      = "Microsoft.EventHub/namespaces/eventhubs@2021-11-01"
  body = {
    properties = {
      messageRetentionInDays = 1
      partitionCount         = 2
      status                 = "Active"
    }
  }
}

resource "azapi_resource" "authorization_rule" {
  name      = "streamlogs"
  parent_id = azapi_resource.eventhub_namespace.id
  type      = "Microsoft.EventHub/namespaces/authorizationRules@2024-01-01"
  body = {
    properties = {
      rights = [
        "Listen",
        "Manage",
        "Send"
      ]
    }
  }
}

resource "azapi_resource" "uami" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
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
  diagnostic_settings = {
    workspace_diag = {
      name                  = "workspaceandstorage_diag"
      metrics               = [{ category = "AllMetrics" }]
      logs                  = [for category in ["JobLogs", "JobStreams", "AuditEvent"] : { category = category }]
      workspace_resource_id = azapi_resource.workspace.id
      #log_analytics_destination_type = "Dedicated"
      #marketplace_partner_resource_id          = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{partnerResourceProvider}/{partnerResourceType}/{partnerResourceName}"
    }
    eventhub_diag = {
      name                                     = "eventhubforwarding"
      logs                                     = [{ category_group = "allLogs" }]
      metrics                                  = [{ category = "AllMetrics" }]
      event_hub_authorization_rule_resource_id = azapi_resource.authorization_rule.id
      event_hub_name                           = azapi_resource.eventhub.name
    }
  }
  enable_telemetry = var.enable_telemetry
  managed_identities = {
    system_assigned = true
    user_assigned_resource_ids = [
      azapi_resource.uami.id
    ]
  }
  public_network_access_enabled = true
  role_assignments = {
    self_contributor = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = data.azapi_client_config.current.object_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Reader"
      principal_id                     = data.azapi_client_config.current.object_id # replace the principal id with appropriate one
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
