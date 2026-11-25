resource "azapi_resource" "automation_account_source_controls" {
  for_each = nonsensitive({
    for key, control in var.automation_source_controls : key => {
      name                    = control.name
      automatic_sync          = control.automatic_sync
      branch                  = control.branch
      description             = control.description
      folder_path             = control.folder_path
      publish_runbook_enabled = control.publish_runbook_enabled
      repository_url          = control.repository_url
      source_control_type     = control.source_control_type
      security_token_version  = control.security_token_version
      timeouts                = control.timeouts
    }
  })

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_source_controls
  body = {
    properties = {
      autoSync       = each.value.automatic_sync
      branch         = each.value.branch
      description    = each.value.description
      folderPath     = each.value.folder_path
      publishRunbook = each.value.publish_runbook_enabled
      repoUrl        = each.value.repository_url
      sourceType     = each.value.source_control_type
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_source_controls) > 0 ? var.ignore_body_changes.automation_automation_accounts_source_controls : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  sensitive_body = {
    properties = {
      securityToken = {
        accessToken  = var.automation_source_controls[each.key].security.token
        refreshToken = var.automation_source_controls[each.key].security.refresh_token
        tokenType    = lower(var.automation_source_controls[each.key].security.token_type) == "oauth" ? "Oauth" : "PersonalAccessToken"
      }
    }
  }
  sensitive_body_version = {
    "properties.securityToken" = tostring(each.value.security_token_version)
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
  from = azurerm_automation_source_control.this
  to   = azapi_resource.automation_account_source_controls
}
