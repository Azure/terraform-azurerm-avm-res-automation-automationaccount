resource "azurerm_automation_certificate" "this" {
#for_each = var.automation_certificate == null ? [] : { for idx, cert in var.automation_certificate : idx => cert }

  automation_account_name = var.automation_certificate.automation_account_name
  base64                  = var.automation_certificate.base64
  name                    = var.automation_certificate.name
  resource_group_name     = var.automation_certificate.resource_group_name
  description             = var.automation_certificate.description
  exportable              = var.automation_certificate.exportable

  dynamic "timeouts" {
    for_each = var.automation_certificate.timeouts == null ? [] : [var.automation_certificate.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}


