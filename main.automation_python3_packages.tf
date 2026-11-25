resource "azapi_resource" "automation_account_python3_packages" {
  for_each = var.automation_python3_packages != null ? var.automation_python3_packages : {}

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_python3_packages
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
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_python3_packages) > 0 ? var.ignore_body_changes.automation_automation_accounts_python3_packages : null
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
      error_message = "Python package hash_algorithm and hash_value must either both be supplied or both be omitted."
    }
  }
}

moved {
  from = azurerm_automation_python3_package.this
  to   = azapi_resource.automation_account_python3_packages
}
