resource "azurerm_automation_certificate" "this" {
  for_each = var.automation_certificates != null ? var.automation_certificates : {}

  automation_account_name = azurerm_automation_account.this.name
  base64                  = each.value.base64
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  description             = each.value.description
  exportable              = each.value.exportable

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


