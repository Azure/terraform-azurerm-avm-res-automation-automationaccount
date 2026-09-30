resource "azurerm_automation_source_control" "this" {
  for_each = keys(var.automation_source_controls) != null ? toset(keys(var.automation_source_controls)) : []

  automation_account_id   = azurerm_automation_account.this.id
  folder_path             = var.automation_source_controls[each.key].folder_path
  name                    = var.automation_source_controls[each.key].name
  repository_url          = var.automation_source_controls[each.key].repository_url
  source_control_type     = var.automation_source_controls[each.key].source_control_type
  automatic_sync          = var.automation_source_controls[each.key].automatic_sync
  branch                  = var.automation_source_controls[each.key].branch
  description             = var.automation_source_controls[each.key].description
  publish_runbook_enabled = var.automation_source_controls[each.key].publish_runbook_enabled

  dynamic "security" {
    for_each = var.automation_source_controls[each.key].security == null ? [] : [var.automation_source_controls[each.key].security]

    content {
      token         = security.value.token
      token_type    = security.value.token_type
      refresh_token = security.value.refresh_token
    }
  }

  dynamic "timeouts" {
    for_each = var.automation_source_controls[each.key].timeouts == null ? [] : [var.automation_source_controls[each.key].timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
