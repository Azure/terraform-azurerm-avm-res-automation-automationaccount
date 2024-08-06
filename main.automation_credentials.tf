resource "azurerm_automation_credential" "this" {
for_each = var.automation_credentials != null ? var.automation_credentials : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  password                = each.value.password
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  username                = each.value.username
  description             = each.value.description

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

