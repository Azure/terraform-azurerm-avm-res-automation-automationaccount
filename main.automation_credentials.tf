resource "azapi_resource" "automation_accounts_credential" {
  for_each = nonsensitive({
    for key, credential in var.automation_credentials : key => {
      name             = credential.name
      username         = credential.username
      description      = credential.description
      password_version = credential.password_version
      timeouts         = credential.timeouts
    }
  })

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_credentials
  body = {
    properties = {
      description = each.value.description
      userName    = each.value.username
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_credentials) > 0 ? var.ignore_body_changes.automation_automation_accounts_credentials : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = {
    properties = {
      password = var.automation_credentials[each.key].password
    }
  }
  sensitive_body_version = {
    "properties.password" = tostring(each.value.password_version)
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
  from = azurerm_automation_credential.this
  to   = azapi_resource.automation_accounts_credential
}
