resource "azurerm_automation_hybrid_runbook_worker_group" "this" {
  for_each = var.automation_hybrid_runbook_worker_groups != null ? var.automation_hybrid_runbook_worker_groups : {}

  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  credential_name         = each.value.credential_name

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

resource "random_uuid" "this" {}

resource "azurerm_automation_hybrid_runbook_worker" "this" {
  for_each = var.automation_hybrid_runbook_workers != null ? var.automation_hybrid_runbook_workers : {}

  automation_account_name = azurerm_automation_account.this.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  vm_resource_id          = each.value.vm_resource_id
  worker_group_name       = azurerm_automation_hybrid_runbook_worker_group.this[each.value.hybrid_worker_group_key].name
  worker_id               = random_uuid.this.result
}