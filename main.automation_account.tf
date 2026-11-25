resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.automation_automation_accounts
  body = {
    properties = {
      disableLocalAuth = !var.local_authentication_enabled
      encryption = {
        keySource = local.customer_managed_encryption ? "Microsoft.Keyvault" : "Microsoft.Automation"
        identity = local.customer_managed_encryption ? {
          userAssignedIdentity = local.encryption_identity_resource_id
        } : null
        keyVaultProperties = local.customer_managed_encryption ? {
          keyName     = local.encryption_key_name
          keyvaultUri = local.encryption_vault_uri
          keyVersion  = local.encryption_key_version
        } : null
      }
      publicNetworkAccess = var.public_network_access_enabled
      sku                 = var.sku
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.automation_automation_accounts) > 0 ? var.ignore_body_changes.automation_automation_accounts : null
  ignore_null_property   = true
  response_export_values = ["properties.automationHybridServiceUrl"]
  retry                  = var.retry
  tags                   = var.tags

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi == null ? [] : [module.avm_interfaces.managed_identities_azapi]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }

  }

  lifecycle {
    precondition {
      condition     = var.customer_managed_key == null ? true : var.customer_managed_key.user_assigned_identity != null
      error_message = "`customer_managed_key.user_assigned_identity.resource_id` is required for Automation Account encryption."
    }
    precondition {
      condition     = !local.customer_managed_encryption || contains(var.managed_identities.user_assigned_resource_ids, local.encryption_identity_resource_id)
      error_message = "The encryption identity must also be supplied in `managed_identities.user_assigned_resource_ids`."
    }
  }
}

data "azapi_resource" "encryption_key_vault" {
  count = var.customer_managed_key == null ? 0 : 1

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = "Microsoft.KeyVault/vaults@2024-11-01"
  response_export_values = ["properties.vaultUri"]
}

moved {
  from = azurerm_automation_account.this
  to   = azapi_resource.this
}
