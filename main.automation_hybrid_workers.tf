resource "azapi_resource" "automation_accounts_hybrid_runbook_worker_group" {
  for_each = var.automation_hybrid_runbook_worker_groups != null ? var.automation_hybrid_runbook_worker_groups : {}

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_hybrid_runbook_worker_groups
  body = {
    properties = {
      credential = {
        name = each.value.credential_name
      }
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_hybrid_runbook_worker_groups) > 0 ? var.ignore_body_changes.automation_automation_accounts_hybrid_runbook_worker_groups : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry

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
  from = azurerm_automation_hybrid_runbook_worker_group.this
  to   = azapi_resource.automation_accounts_hybrid_runbook_worker_group
}

resource "random_uuid" "this" {
  for_each = var.automation_hybrid_runbook_workers != null ? var.automation_hybrid_runbook_workers : {}
}

resource "azapi_resource" "automation_accounts_hybrid_runbook_worker_groups_workers" {
  for_each = var.automation_hybrid_runbook_workers != null ? var.automation_hybrid_runbook_workers : {}

  name      = random_uuid.this[each.key].result
  parent_id = azapi_resource.automation_accounts_hybrid_runbook_worker_group[each.value.hybrid_worker_group_key].id
  type      = var.resource_types.automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers
  body = {
    properties = {
      vmResourceId = each.value.vm_resource_id
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers) > 0 ? var.ignore_body_changes.automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry

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
  from = azurerm_automation_hybrid_runbook_worker.this
  to   = azapi_resource.automation_accounts_hybrid_runbook_worker_groups_workers
}
