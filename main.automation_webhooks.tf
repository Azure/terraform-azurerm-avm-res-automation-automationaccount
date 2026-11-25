resource "terraform_data" "automation_webhook_uri_versions" {
  for_each = nonsensitive({
    for key, webhook in var.automation_webhooks : key => {
      uri_version = webhook.uri_version
      name        = webhook.name
      expiry_time = webhook.expiry_time
    } if webhook.uri == null
  })

  input = each.value
}

resource "azapi_resource_action" "automation_webhook_uris" {
  for_each = terraform_data.automation_webhook_uri_versions

  action                 = "webhooks/generateUri"
  method                 = "POST"
  resource_id            = azapi_resource.this.id
  type                   = var.resource_types.automation_automation_accounts
  response_export_values = []
  retry                  = var.retry
  sensitive_response_export_values = {
    uri = "@"
  }
  when = "apply"

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
    replace_triggered_by = [terraform_data.automation_webhook_uri_versions[each.key]]
  }
}

resource "azapi_resource" "automation_account_webhooks" {
  for_each = nonsensitive({
    for key, webhook in var.automation_webhooks : key => {
      name                = webhook.name
      expiry_time         = webhook.expiry_time
      enabled             = webhook.enabled
      runbook_key         = webhook.runbook_key
      run_on_worker_group = webhook.run_on_worker_group
      uri_version         = webhook.uri_version
    }
  })

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_webhooks
  body = {
    properties = {
      expiryTime = each.value.expiry_time
      isEnabled  = each.value.enabled
      parameters = var.automation_webhooks[each.key].parameters
      runOn      = each.value.run_on_worker_group
      runbook = {
        name = azapi_resource.automation_account_runbooks[each.value.runbook_key].name
      }
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_webhooks) > 0 ? var.ignore_body_changes.automation_automation_accounts_webhooks : null
  # Azure picks its own destination type when none is requested.
  ignore_null_property = true
  replace_triggers_external_values = {
    uri_version = each.value.uri_version
  }
  replace_triggers_refs  = ["properties.expiryTime"]
  response_export_values = []
  retry                  = var.retry
  sensitive_body = {
    properties = {
      uri = var.automation_webhooks[each.key].uri != null ? var.automation_webhooks[each.key].uri : azapi_resource_action.automation_webhook_uris[each.key].sensitive_output.uri
    }
  }
  sensitive_body_version = {
    "properties.uri" = tostring(each.value.uri_version)
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azapi_resource.automation_account_runbooks, azapi_resource_action.automation_account_runbook_publish]
}

moved {
  from = azurerm_automation_webhook.this
  to   = azapi_resource.automation_account_webhooks
}
