resource "azurerm_automation_connection" "this" {
  for_each                = var.automation_connection != null ? var.automation_connection : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  type                    = each.value.type
  values                  = each.value.values
  description             = each.value.description

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? { "dummy_key" : each.value.timeouts } : {}
    content {
      create = each.value.timeouts.create
      delete = each.value.timeouts.delete
      read   = each.value.timeouts.read
      update = each.value.timeouts.update
    }
  }
}

