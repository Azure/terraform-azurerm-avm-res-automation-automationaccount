resource "azurerm_automation_schedule" "this" {
  automation_account_name = var.automation_schedule_automation_account_name
  frequency               = var.automation_schedule_frequency
  name                    = var.automation_schedule_name
  resource_group_name     = var.automation_schedule_resource_group_name
  description             = var.automation_schedule_description
  expiry_time             = var.automation_schedule_expiry_time
  interval                = var.automation_schedule_interval
  month_days              = var.automation_schedule_month_days
  start_time              = var.automation_schedule_start_time
  timezone                = var.automation_schedule_timezone
  week_days               = var.automation_schedule_week_days

  dynamic "monthly_occurrence" {
    for_each = var.automation_schedule_monthly_occurrence == null ? [] : [var.automation_schedule_monthly_occurrence]
    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
  dynamic "timeouts" {
    for_each = var.automation_schedule_timeouts == null ? [] : [var.automation_schedule_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

