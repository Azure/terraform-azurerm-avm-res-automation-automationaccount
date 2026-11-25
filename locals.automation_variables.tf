locals {
  automation_variable_metadata = {
    for kind, variables in {
      bools     = var.automation_variable_bools
      datetimes = var.automation_variable_datetimes
      ints      = var.automation_variable_ints
      objects   = var.automation_variable_objects
      strings   = var.automation_variable_strings
      } : kind => nonsensitive({
        for key, variable in variables : key => {
          name          = variable.name
          description   = variable.description
          encrypted     = variable.encrypted
          value_version = variable.value_version
        }
    })
  }
  automation_variable_bools = {
    for key, value in var.automation_variable_bools : key => {
      name        = value.name
      value       = tostring(value.value)
      description = value.description
      encrypted   = value.encrypted
    }
  }
  automation_variable_datetimes = {
    for key, value in var.automation_variable_datetimes : key => {
      name        = value.name
      value       = "\"\\/Date(${time_static.datetimes[key].unix}000)\\/\""
      description = value.description
      encrypted   = value.encrypted
    }
  }
  automation_variable_ints = {
    for key, value in var.automation_variable_ints : key => {
      name        = value.name
      value       = tostring(value.value)
      description = value.description
      encrypted   = value.encrypted
    }
  }
  automation_variable_strings = {
    for key, value in var.automation_variable_strings : key => {
      name        = value.name
      value       = value.value == null ? null : jsonencode(value.value)
      description = value.description
      encrypted   = value.encrypted
    }
  }
}
