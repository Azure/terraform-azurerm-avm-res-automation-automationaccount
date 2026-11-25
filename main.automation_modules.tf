resource "azapi_resource" "automation_account_modules" {
  for_each = var.automation_modules != null ? var.automation_modules : {}

  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_modules
  body = {
    properties = {
      contentLink = {
        contentHash = each.value.hash_algorithm == null ? null : {
          algorithm = each.value.hash_algorithm
          value     = each.value.hash_value
        }
        uri     = each.value.content_uri
        version = each.value.content_version
      }
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_modules) > 0 ? var.ignore_body_changes.automation_automation_accounts_modules : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  tags                   = each.value.tags != null ? each.value.tags : var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = (each.value.hash_algorithm == null) == (each.value.hash_value == null)
      error_message = "Module hash_algorithm and hash_value must either both be supplied or both be omitted."
    }
  }
}

moved {
  from = azurerm_automation_module.this
  to   = azapi_resource.automation_account_modules
}

resource "azapi_resource" "automation_account_powershell72_modules" {
  for_each = var.automation_powershell72_modules != null ? var.automation_powershell72_modules : {}

  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_power_shell72_modules
  body = {
    properties = {
      contentLink = {
        contentHash = each.value.hash_algorithm == null ? null : {
          algorithm = each.value.hash_algorithm
          value     = each.value.hash_value
        }
        uri     = each.value.content_uri
        version = each.value.content_version
      }
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_power_shell72_modules) > 0 ? var.ignore_body_changes.automation_automation_accounts_power_shell72_modules : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  tags                   = each.value.tags != null ? each.value.tags : var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = (each.value.hash_algorithm == null) == (each.value.hash_value == null)
      error_message = "PowerShell 7.2 module hash_algorithm and hash_value must either both be supplied or both be omitted."
    }
  }
}

moved {
  from = azurerm_automation_powershell72_module.this
  to   = azapi_resource.automation_account_powershell72_modules
}
