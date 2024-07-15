resource "azurerm_automation_connection" "this" {
for_each = var.automation_connection != null ? var.automation_connection : {}
  automation_account_name = each.value.automation_account_name
  name                    = each.value.name
  resource_group_name     = each.value.resource_group_name
  type                    = each.value.type
  values                  = each.value.values
  description             = each.value.description
  
  timeouts {
    create = each.value.timeouts.create
    delete = each.value.timeouts.delete
    read   = each.value.timeouts.read
    update = each.value.timeouts.update
  }
}

