resource "azapi_resource" "automation_account_watchers" {
  for_each = var.automation_watchers != null ? var.automation_watchers : {}

  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_watchers
  body = {
    etag = each.value.etag
    properties = {
      description                 = each.value.description
      executionFrequencyInSeconds = each.value.execution_frequency_in_seconds
      scriptName                  = azapi_resource.automation_account_runbooks[each.value.runbook_key].name
      scriptParameters            = each.value.script_parameters
      scriptRunOn                 = each.value.hybrid_worker_group_key == "Azure" ? "Azure" : azapi_resource.automation_accounts_hybrid_runbook_worker_group[each.value.hybrid_worker_group_key].name
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_watchers) > 0 ? var.ignore_body_changes.automation_automation_accounts_watchers : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  tags                   = each.value.tags != null ? each.value.tags : var.tags

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

moved {
  from = azurerm_automation_watcher.this
  to   = azapi_resource.automation_account_watchers
}
