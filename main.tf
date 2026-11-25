# Role definitions are resolved here, case-insensitively as the AzureRM provider did, rather than by
# the interfaces module, whose lookup is case-sensitive. They are listed in the resource group rather
# than on the automation account, so the lookup does not wait for pending changes to the automation account
# and a role name that does not exist fails during plan.
data "azapi_resource_list" "role_definitions" {
  count = length(local.all_role_assignments) > 0 ? 1 : 0

  parent_id = var.parent_id
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  response_export_values = {
    results = "value[].{id: id, role_name: properties.roleName}"
  }
}

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.9.0"

  location                                  = var.location
  diagnostic_settings_v2                    = var.diagnostic_settings
  enable_telemetry                          = var.enable_telemetry
  managed_identities                        = var.managed_identities
  role_assignment_definition_lookup_enabled = false
  role_assignments                          = local.role_assignments
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.name}")
  parent_id = azapi_resource.this.id
  type      = var.resource_types.authorization_locks
  body = {
    properties = merge(
      { level = var.lock.kind },
      var.lock.notes == null ? {} : { notes = var.lock.notes },
    )
  }
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # Create the lock last and remove it first. A ReadOnly lock blocks changes to the child resources.
  depends_on = [
    azapi_resource.automation_account_certificates,
    azapi_resource.automation_account_connections,
    azapi_resource.automation_accounts_credential,
    azapi_resource.automation_accounts_hybrid_runbook_worker_group,
    azapi_resource.automation_accounts_hybrid_runbook_worker_groups_workers,
    azapi_resource.automation_account_job_schedules,
    azapi_resource.automation_account_modules,
    azapi_resource.automation_account_powershell72_modules,
    azapi_resource.automation_account_python3_packages,
    azapi_resource.automation_account_runbooks,
    azapi_resource.automation_account_schedules,
    azapi_resource.automation_account_source_controls,
    azapi_resource.automation_account_variable_bools,
    azapi_resource.automation_account_variable_datetimes,
    azapi_resource.automation_account_variable_ints,
    azapi_resource.automation_account_variable_objects,
    azapi_resource.automation_account_variable_strings,
    azapi_resource.automation_account_watchers,
    azapi_resource.automation_account_webhooks,
    azapi_resource_action.automation_account_runbook_publish,
    azapi_resource.diagnostic_settings,
    azapi_resource.private_dns_zone_groups,
    azapi_resource.private_endpoints,
    azapi_resource.private_endpoints_unmanaged_dns_zone_groups,
    azapi_resource.role_assignments,
    azapi_resource.private_endpoint_role_assignments,
    azapi_resource.this,
  ]
}

moved {
  from = azurerm_management_lock.this
  to   = azapi_resource.lock
}

resource "azapi_resource" "role_assignments" {
  for_each = var.role_assignments

  name                 = module.avm_interfaces.role_assignments_azapi[jsonencode(["root", each.key])].name
  parent_id            = azapi_resource.this.id
  type                 = var.resource_types.authorization_role_assignments
  body                 = module.avm_interfaces.role_assignments_azapi[jsonencode(["root", each.key])].body
  ignore_body_changes  = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  ignore_casing        = true
  ignore_null_property = true
  # The AzureRM provider replaced a role assignment whenever one of its inputs changed. The inputs are
  # compared, rather than body paths or the resolved role definition ID: Azure normalises role
  # definition IDs, and the role definition lookup is deferred to apply whenever the resource group is
  # not yet known. While the prior value is null, as it is straight after upgrading from AzureRM,
  # nothing is replaced.
  replace_triggers_external_values = {
    condition                              = each.value.condition
    condition_version                      = each.value.condition_version
    delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
    description                            = each.value.description
    principal_id                           = lower(each.value.principal_id)
    principal_type                         = local.role_assignments[jsonencode(["root", each.key])].principal_type
    role_definition_id_or_name             = lower(each.value.role_definition_id_or_name)
  }
  response_export_values = []
  retry                  = var.retry

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
    # Upgraded assignments keep the GUID azurerm generated, while the interfaces module generates a
    # new one. Replacing the assignment would fail with ScopeLocked under a CanNotDelete lock.
    ignore_changes = [name]

    precondition {
      condition     = strcontains(lower(local.role_assignments[jsonencode(["root", each.key])].role_definition_id_or_name), local.role_definition_resource_substring)
      error_message = "The role definition `${each.value.role_definition_id_or_name}` was not found in the resource group. Use the name of a role definition that can be assigned there, or the role definition's resource ID."
    }
  }
}

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignments
}

resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi_v2

  name                = each.value.name != null ? each.value.name : "diag-${var.name}"
  parent_id           = azapi_resource.this.id
  type                = var.resource_types.insights_diagnostic_settings
  body                = each.value.body
  ignore_body_changes = length(var.ignore_body_changes.insights_diagnostic_settings) > 0 ? var.ignore_body_changes.insights_diagnostic_settings : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

moved {
  from = azurerm_monitor_diagnostic_setting.this
  to   = azapi_resource.diagnostic_settings
}
