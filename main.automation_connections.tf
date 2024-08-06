resource "azurerm_automation_connection" "this" {
  for_each                = var.automation_connections != null ? var.automation_connections : {}
  automation_account_name = azurerm_automation_account.this.name
  name                    = each.value.name
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  type                    = each.value.type
  values                  = each.value.values
  description             = each.value.description

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? { "dummy_key" : each.value.timeouts } : {}
    content {
      create = each.value.timeouts.create
      delete = each.value.timeouts.delete
      read   = each.value.timeouts.read
      update = each.value.timeouts.update
    }
  }
}

resource "azurerm_automation_connection_certificate" "this" {
  for_each                = var.automation_connection_certificates != null ? var.automation_connection_certificates : {}
    automation_account_name = azurerm_automation_account.this.name
    name                    = azurerm_automation_connection.this[each.value.connection_key].name
    resource_group_name     = azurerm_automation_account.this.resource_group_name
    automation_certificate_name = each.value.automation_certificate_name
    subscription_id = each.value.subscription_id

}

resource "azurerm_automation_connection_service_principal" "this" {
  for_each                = var.automation_connection_service_principals != null ? var.automation_connection_service_principals : {}
    automation_account_name = azurerm_automation_account.this.name
    name                    = azurerm_automation_connection.this[each.value.connection_key].name
    resource_group_name     = azurerm_automation_account.this.resource_group_name
    application_id = each.value.application_id
    tenant_id = each.value.tenant_id
    subscription_id = each.value.subscription_id
    certificate_thumbprint = each.value.certificate_thumbprint
}

resource "azurerm_automation_connection_classic_certificate" "this" {
  for_each                = var.automation_connection_classic_certificates != null ? var.automation_connection_classic_certificates : {}
    automation_account_name = azurerm_automation_account.this.name
    name                    = azurerm_automation_connection.this[each.value.connection_key].name
    resource_group_name     = azurerm_automation_account.this.resource_group_name
    certificate_asset_name  = each.value.certificate_asset_name
    subscription_id = each.value.subscription_id
    subscription_name = each.value.subscription_name
}