resource "azurerm_automation_watcher" "this" {
  for_each                       = var.automation_watchers != null ? var.automation_watchers : {}
  name                           = each.value.name
  automation_account_id          = azurerm_automation_account.this.id
  execution_frequency_in_seconds = each.value.execution_frequency_in_seconds
  location                       = azurerm_automation_account.this.location
  script_name                    = azurerm_automation_runbook.this[each.value.runbook_key].name
  script_run_on                  = each.value.hybrid_worker_group_key == "Azure" ? "Azure" : azurerm_automation_hybrid_runbook_worker_group.this[each.value.hybrid_worker_group_key].name
  description                    = each.value.description
  etag                           = each.value.etag
  tags                           = each.value.tags
  script_parameters              = each.value.script_parameters

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