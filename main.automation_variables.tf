resource "azurerm_automation_variable_bool" "this" {
  for_each                = var.automation_variable_bools != null ? var.automation_variable_bools : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted

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

resource "azurerm_automation_variable_datetime" "this" {
  for_each                = var.automation_variable_datetimes != null ? var.automation_variable_datetimes : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted

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

resource "azurerm_automation_variable_int" "this" {
  for_each                = var.automation_variable_ints != null ? var.automation_variable_ints : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted

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

resource "azurerm_automation_variable_object" "this" {
  for_each                = var.automation_variable_objects != null ? var.automation_variable_objects : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted

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

resource "azurerm_automation_variable_string" "this" {
  for_each                = var.automation_variable_strings != null ? var.automation_variable_strings : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted

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