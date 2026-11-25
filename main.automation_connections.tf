resource "azapi_resource" "automation_account_connections" {
  for_each = local.automation_connections

  name      = each.value.name
  parent_id = azapi_resource.this.id
  type      = var.resource_types.automation_automation_accounts_connections
  body = {
    properties = {
      connectionType = {
        name = each.value.type
      }
      description           = each.value.description
      fieldDefinitionValues = each.value.values
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.automation_automation_accounts_connections) > 0 ? var.ignore_body_changes.automation_automation_accounts_connections : null
  replace_triggers_refs = [
    "properties.connectionType.name",
  ]
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : (var.timeouts == null ? [] : [var.timeouts])

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for field in lookup({
          Azure                   = ["AutomationCertificateName", "SubscriptionID"]
          AzureServicePrincipal   = ["TenantId", "ApplicationId", "CertificateThumbprint", "SubscriptionId"]
          AzureClassicCertificate = ["SubscriptionId", "SubscriptionName", "CertificateAssetName"]
        }, each.value.type, []) : contains(keys(each.value.values), field)
      ])
      error_message = "The merged connection values must include all required fields for the selected built-in connection type."
    }
  }
}

moved {
  from = azurerm_automation_connection.this
  to   = azapi_resource.automation_account_connections
}

removed {
  from = azurerm_automation_connection_certificate.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = azurerm_automation_connection_service_principal.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = azurerm_automation_connection_classic_certificate.this

  lifecycle {
    destroy = false
  }
}
