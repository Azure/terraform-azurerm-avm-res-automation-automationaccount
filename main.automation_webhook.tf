resource "azurerm_automation_webhook" "this" {
for_each = var.automation_webhook != null ? var.automation_webhook : {}
  automation_account_name = azurerm_automation_account.this.name
  expiry_time             = each.value.expiry_time
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  runbook_name           =  each.value.runbook_name
  enabled                 = each.value.enabled
  parameters              = each.value.parameters
  run_on_worker_group     = each.value.run_on_worker_group
  uri                     = each.value.uri

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

