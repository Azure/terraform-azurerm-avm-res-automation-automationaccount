resource "azapi_resource" "automation_account_job_schedules" {
  for_each = local.automation_job_schedules

  name      = each.value.job_schedule_id != null ? each.value.job_schedule_id : uuidv5("url", "${azapi_resource.this.id}/jobSchedules/${each.key}")
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_job_schedules
  body = {
    properties = {
      runbook = {
        name = azapi_resource.automation_account_runbooks[each.value.runbook_key].name
      }
      schedule = {
        name = azapi_resource.automation_account_schedules[each.value.schedule_key].name
      }
      parameters = each.value.parameters
      runOn      = each.value.run_on
    }
  }
  ignore_body_changes  = length(var.ignore_body_changes.automation_automation_accounts_job_schedules) > 0 ? var.ignore_body_changes.automation_automation_accounts_job_schedules : null
  ignore_null_property = true
  replace_triggers_refs = [
    "properties.runbook.name",
    "properties.schedule.name",
    "properties.parameters",
    "properties.runOn",
  ]
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : (
      !contains(keys(var.automation_job_schedules), each.key) && var.automation_runbooks[each.value.runbook_key].timeouts != null ?
      [var.automation_runbooks[each.value.runbook_key].timeouts] :
      (var.timeouts == null ? [] : [var.timeouts])
    )

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.parameters == null ? true : alltrue([for key in keys(each.value.parameters) : key == lower(key)])
      error_message = "Job schedule parameter names must be lowercase."
    }
  }
  depends_on = [azapi_resource_action.automation_account_runbook_publish]
}

import {
  for_each = {
    for key, job in local.automation_job_schedules : key => job
    if job.job_schedule_id != null
  }

  to = azapi_resource.automation_account_job_schedules[each.key]
  id = "${azapi_resource.this.id}/jobSchedules/${each.value.job_schedule_id}"
}

removed {
  from = azurerm_automation_job_schedule.this

  lifecycle {
    destroy = false
  }
}
