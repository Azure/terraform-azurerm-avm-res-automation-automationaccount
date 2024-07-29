resource "azurerm_automation_python3_package" "this" {
for_each = var.automation_python3_packages != null ? var.automation_python3_packages : {}
  automation_account_name = azurerm_automation_account.this.name
  content_uri             = each.value.content_uri
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  content_version         = each.value.content_version
  hash_algorithm          = each.value.hash_algorithm
  hash_value              = each.value.hash_value
  tags                    = each.value.tags

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
