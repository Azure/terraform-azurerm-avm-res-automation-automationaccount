resource "azurerm_automation_connection" "this" {
#for_each = var.automation_connection == null ? [] : { for idx, cert in var.automation_connection : idx => cert }

  automation_account_name = var.automation_connection.automation_account_name
  name                    = var.automation_connection.name
  resource_group_name     = var.automation_connection.resource_group_name
  type                    = var.automation_connection.type
  values                  = var.automation_connection.values
  description             = var.automation_connection.description

  dynamic "timeouts" {
    for_each = var.automation_connection.timeouts == null ? [] : [var.automation_connection.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

