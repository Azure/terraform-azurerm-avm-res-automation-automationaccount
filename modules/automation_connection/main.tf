resource "azurerm_automation_connection" "this" {
  automation_account_name = var.automation_connection_automation_account_name
  name                    = var.automation_connection_name
  resource_group_name     = var.automation_connection_resource_group_name
  type                    = var.automation_connection_type
  values                  = var.automation_connection_values
  description             = var.automation_connection_description

  dynamic "timeouts" {
    for_each = var.automation_connection_timeouts == null ? [] : [var.automation_connection_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

