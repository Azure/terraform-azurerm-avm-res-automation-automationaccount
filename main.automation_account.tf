resource "azurerm_automation_account" "this" {
  location                      = var.location
  name                          = var.name
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku
  local_authentication_enabled  = var.local_authentication_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  dynamic "encryption" {
    for_each = var.encryption == null ? [] : var.encryption

    content {
      key_vault_key_id = encryption.value.key_vault_key_id
      #key_source                = encryption.value.key_source #This is deprecated
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }
  #   content {
  #     type         = identity.value.type
  #     identity_ids = identity.value.identity_ids
  #   }
  # }
  ## Resources supporting both SystemAssigned and UserAssigned
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
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
}


resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_automation_account.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}