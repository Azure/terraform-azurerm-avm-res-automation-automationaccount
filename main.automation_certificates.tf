resource "azapi_resource" "automation_account_certificates" {
  for_each = nonsensitive({
    for key, certificate in var.automation_certificates : key => {
      name           = certificate.name
      description    = certificate.description
      exportable     = certificate.exportable
      thumbprint     = certificate.thumbprint
      base64_version = certificate.base64_version
      timeouts       = certificate.timeouts
    }
  })

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_certificates
  body = {
    properties = {
      description  = each.value.description
      isExportable = each.value.exportable
      thumbprint   = each.value.thumbprint
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_certificates) > 0 ? var.ignore_body_changes.automation_automation_accounts_certificates : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = {
    properties = {
      base64Value = var.automation_certificates[each.key].base64
    }
  }
  sensitive_body_version = {
    "properties.base64Value" = tostring(each.value.base64_version)
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : (var.timeouts == null ? [] : [var.timeouts])

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

moved {
  from = azurerm_automation_certificate.this
  to   = azapi_resource.automation_account_certificates
}
