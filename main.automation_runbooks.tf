resource "azapi_resource" "automation_account_runbooks" {
  for_each = var.automation_runbooks != null ? var.automation_runbooks : {}

  location  = azapi_resource.this.location
  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_runbooks
  body = {
    properties = {
      description = each.value.description
      draft = each.value.draft != null ? {
        inEdit = each.value.draft.edit_mode_enabled
        draftContentLink = each.value.draft.content_link != null ? {
          contentHash = each.value.draft.content_link.hash != null ? {
            algorithm = each.value.draft.content_link.hash.algorithm
            value     = each.value.draft.content_link.hash.value
          } : null
          uri     = each.value.draft.content_link.uri
          version = each.value.draft.content_link.version
        } : null
        outputTypes = each.value.draft.output_types
        parameters = each.value.draft.parameters == null ? null : { for v in each.value.draft.parameters : v.key => {
          defaultValue = v.default_value
          isMandatory  = v.mandatory
          position     = v.position
          type         = v.type
          }
        }
      } : null
      logActivityTrace = each.value.log_activity_trace_level
      logProgress      = each.value.log_progress
      logVerbose       = each.value.log_verbose
      publishContentLink = each.value.publish_content_link != null ? {
        contentHash = each.value.publish_content_link.hash != null ? {
          algorithm = each.value.publish_content_link.hash.algorithm
          value     = each.value.publish_content_link.hash.value
        } : null
        uri     = each.value.publish_content_link.uri
        version = each.value.publish_content_link.version
      } : null
      runbookType = each.value.runbook_type
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.automation_automation_accounts_runbooks) > 0 ? var.ignore_body_changes.automation_automation_accounts_runbooks : null
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry
  tags                   = each.value.tags != null ? each.value.tags : var.tags

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? (var.timeouts == null ? [] : [var.timeouts]) : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "terraform_data" "automation_account_runbook_publish" {
  for_each = {
    for key, runbook in var.automation_runbooks : key => runbook
    if runbook.draft == null ? false : (runbook.draft.content_link != null && runbook.draft.edit_mode_enabled == false)
  }

  input = each.value.draft
}

# Replacing an apply-time action only republishes; it never deletes the runbook.
resource "azapi_resource_action" "automation_account_runbook_publish" {
  for_each = terraform_data.automation_account_runbook_publish

  action                 = "publish"
  method                 = "POST"
  resource_id            = azapi_resource.automation_account_runbooks[each.key].id
  type                   = var.resource_types.automation_automation_accounts_runbooks
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.automation_runbooks[each.key].timeouts == null ? (var.timeouts == null ? [] : [var.timeouts]) : [var.automation_runbooks[each.key].timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    replace_triggered_by = [terraform_data.automation_account_runbook_publish[each.key]]
  }
}

moved {
  from = azurerm_automation_runbook.this
  to   = azapi_resource.automation_account_runbooks
}
