resource "time_static" "automation_account_schedule_start" {
  for_each = {
    for key, schedule in var.automation_schedules : key => schedule
    if schedule.start_time == null
  }

  triggers = {
    name      = each.value.name
    parent_id = azapi_resource.this.id
  }
}

resource "azapi_resource" "automation_account_schedules" {
  for_each = var.automation_schedules != null ? var.automation_schedules : {}

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_schedules
  body = {
    properties = {
      advancedSchedule = {
        monthDays = each.value.month_days
        monthlyOccurrences = each.value.monthly_occurrence != null ? [
          {
            day        = each.value.monthly_occurrence.day
            occurrence = each.value.monthly_occurrence.occurrence
          }
        ] : null
        weekDays = each.value.week_days
      }
      description = each.value.description
      expiryTime  = each.value.expiry_time
      frequency   = each.value.frequency
      interval    = each.value.frequency == "OneTime" ? null : each.value.interval
      startTime   = each.value.start_time != null ? each.value.start_time : timeadd(time_static.automation_account_schedule_start[each.key].rfc3339, "7m")
      timeZone    = each.value.timezone
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.automation_automation_accounts_schedules) > 0 ? var.ignore_body_changes.automation_automation_accounts_schedules : null
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? (var.timeouts == null ? [] : [var.timeouts]) : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

moved {
  from = azurerm_automation_schedule.this
  to   = azapi_resource.automation_account_schedules
}
