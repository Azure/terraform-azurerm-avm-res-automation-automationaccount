resource "azurerm_automation_certificate" "this" {
  automation_account_name = var.automation_certificate_automation_account_name
  base64                  = var.automation_certificate_base64
  name                    = var.automation_certificate_name
  resource_group_name     = var.automation_certificate_resource_group_name
  description             = var.automation_certificate_description
  exportable              = var.automation_certificate_exportable

  dynamic "timeouts" {
    for_each = var.automation_certificate_timeouts == null ? [] : [var.automation_certificate_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

