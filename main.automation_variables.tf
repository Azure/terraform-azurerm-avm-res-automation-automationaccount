resource "azapi_resource" "automation_account_variable_bools" {
  for_each = local.automation_variable_metadata.bools

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_variables
  body = {
    properties = {
      description = each.value.description
      isEncrypted = each.value.encrypted
      value       = each.value.encrypted ? null : local.automation_variable_bools[each.key].value
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_variables) > 0 ? var.ignore_body_changes.automation_automation_accounts_variables : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = each.value.encrypted ? {
    properties = { value = local.automation_variable_bools[each.key].value }
  } : null
  sensitive_body_version = each.value.encrypted ? {
    "properties.value" = tostring(each.value.value_version)
  } : null

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
      condition     = each.value.value_version >= 1 && floor(each.value.value_version) == each.value.value_version
      error_message = "Every variable value_version must be a positive integer."
    }
  }
}

moved {
  from = azurerm_automation_variable_bool.this
  to   = azapi_resource.automation_account_variable_bools
}

resource "time_static" "datetimes" {
  for_each = local.automation_variable_metadata.datetimes

  rfc3339 = var.automation_variable_datetimes[each.key].value
}

resource "azapi_resource" "automation_account_variable_datetimes" {
  for_each = local.automation_variable_metadata.datetimes

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_variables
  body = {
    properties = {
      description = each.value.description
      isEncrypted = each.value.encrypted
      value       = each.value.encrypted ? null : local.automation_variable_datetimes[each.key].value
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_variables) > 0 ? var.ignore_body_changes.automation_automation_accounts_variables : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = each.value.encrypted ? {
    properties = { value = local.automation_variable_datetimes[each.key].value }
  } : null
  sensitive_body_version = each.value.encrypted ? {
    "properties.value" = tostring(each.value.value_version)
  } : null

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
      condition     = each.value.value_version >= 1 && floor(each.value.value_version) == each.value.value_version
      error_message = "Every variable value_version must be a positive integer."
    }
  }
}

moved {
  from = azurerm_automation_variable_datetime.this
  to   = azapi_resource.automation_account_variable_datetimes
}

resource "azapi_resource" "automation_account_variable_ints" {
  for_each = local.automation_variable_metadata.ints

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_variables
  body = {
    properties = {
      description = each.value.description
      isEncrypted = each.value.encrypted
      value       = each.value.encrypted ? null : local.automation_variable_ints[each.key].value
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_variables) > 0 ? var.ignore_body_changes.automation_automation_accounts_variables : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = each.value.encrypted ? {
    properties = { value = local.automation_variable_ints[each.key].value }
  } : null
  sensitive_body_version = each.value.encrypted ? {
    "properties.value" = tostring(each.value.value_version)
  } : null

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
      condition     = each.value.value_version >= 1 && floor(each.value.value_version) == each.value.value_version
      error_message = "Every variable value_version must be a positive integer."
    }
  }
}

moved {
  from = azurerm_automation_variable_int.this
  to   = azapi_resource.automation_account_variable_ints
}

resource "azapi_resource" "automation_account_variable_objects" {
  for_each = local.automation_variable_metadata.objects

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_variables
  body = {
    properties = {
      description = each.value.description
      isEncrypted = each.value.encrypted
      value       = each.value.encrypted ? null : var.automation_variable_objects[each.key].value
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_variables) > 0 ? var.ignore_body_changes.automation_automation_accounts_variables : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = each.value.encrypted ? {
    properties = { value = var.automation_variable_objects[each.key].value }
  } : null
  sensitive_body_version = each.value.encrypted ? {
    "properties.value" = tostring(each.value.value_version)
  } : null

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
      condition     = each.value.value_version >= 1 && floor(each.value.value_version) == each.value.value_version
      error_message = "Every variable value_version must be a positive integer."
    }
  }
}

moved {
  from = azurerm_automation_variable_object.this
  to   = azapi_resource.automation_account_variable_objects
}

resource "azapi_resource" "automation_account_variable_strings" {
  for_each = local.automation_variable_metadata.strings

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_variables
  body = {
    properties = {
      description = each.value.description
      isEncrypted = each.value.encrypted
      value       = each.value.encrypted ? null : local.automation_variable_strings[each.key].value
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_variables) > 0 ? var.ignore_body_changes.automation_automation_accounts_variables : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = each.value.encrypted ? {
    properties = { value = local.automation_variable_strings[each.key].value }
  } : null
  sensitive_body_version = each.value.encrypted ? {
    "properties.value" = tostring(each.value.value_version)
  } : null

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
      condition     = each.value.value_version >= 1 && floor(each.value.value_version) == each.value.value_version
      error_message = "Every variable value_version must be a positive integer."
    }
  }
}

moved {
  from = azurerm_automation_variable_string.this
  to   = azapi_resource.automation_account_variable_strings
}
