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
      key_vault_key_id          = encryption.value.key_vault_key_id
      #key_source                = encryption.value.key_source #This is deprecated
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }
  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
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
}


