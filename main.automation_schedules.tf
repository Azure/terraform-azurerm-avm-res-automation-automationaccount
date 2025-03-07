resource "azurerm_automation_schedule" "this" {
  for_each = var.automation_schedules != null ? var.automation_schedules : {}

  automation_account_name = azurerm_automation_account.this.name
  frequency               = each.value.frequency
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  description             = each.value.description
  expiry_time             = each.value.expiry_time
  interval                = each.value.interval
  month_days              = each.value.month_days
  start_time              = each.value.start_time
  timezone                = each.value.timezone
  week_days               = each.value.week_days

  dynamic "monthly_occurrence" {
    for_each = each.value.monthly_occurrence == null ? [] : [each.value.monthly_occurrence]

    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
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

