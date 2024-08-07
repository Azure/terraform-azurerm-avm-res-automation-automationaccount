resource "azurerm_automation_module" "this" {
  for_each                = var.automation_modules != null ? var.automation_modules : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name

  dynamic "module_link" {
    for_each = each.value.module_link == null ? [] : [each.value.module_link]
    content {
      uri = module_link.value.uri

      dynamic "hash" {
        for_each = module_link.value.hash == null ? [] : [module_link.value.hash]
        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
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

resource "azurerm_automation_powershell72_module" "this" {
  for_each              = var.automation_powershell72_modules != null ? var.automation_powershell72_modules : {}
  name                  = each.value.name
  automation_account_id = azurerm_automation_account.this.id

  dynamic "module_link" {
    for_each = each.value.module_link == null ? [] : [each.value.module_link]
    content {
      uri = module_link.value.uri

      dynamic "hash" {
        for_each = module_link.value.hash == null ? [] : [module_link.value.hash]
        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
    }
  }
}    