resource "azurerm_automation_certificate" "this" {
for_each = var.automation_certificate != null ? var.automation_certificate : {}
  automation_account_name = each.value.automation_account_name
  name                    = each.value.name
  resource_group_name     = each.value.resource_group_name
  base64                  = each.value.base64
  description             = each.value.description
  exportable              = each.value.exportable

  timeouts {
    create = each.value.timeouts.create
    delete = each.value.timeouts.delete
    read   = each.value.timeouts.read
    update = each.value.timeouts.update
  }
}


