resource "azurerm_automation_source_control" "this" {
  for_each                = var.automation_source_controls != null ? var.automation_source_controls : {}
  name                    = each.value.name
  automation_account_id   = azurerm_automation_account.this.id
  folder_path             = each.value.folder_path
  repository_url          = each.value.repository_url
  source_control_type     = each.value.source_control_type
  automatic_sync          = each.value.automatic_sync
  branch                  = each.value.branch
  description             = each.value.description
  publish_runbook_enabled = each.value.publish_runbook_enabled

  dynamic "security" {
    for_each = each.value.security == null ? [] : [each.value.security]
    content {
      token         = security.value.token
      token_type    = security.value.token_type
      refresh_token = security.value.refresh_token
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}