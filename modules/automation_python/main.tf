resource "azurerm_automation_python3_package" "this" {
  automation_account_name = var.automation_python3_package_automation_account_name
  content_uri             = var.automation_python3_package_content_uri
  name                    = var.automation_python3_package_name
  resource_group_name     = var.automation_python3_package_resource_group_name
  content_version         = var.automation_python3_package_content_version
  hash_algorithm          = var.automation_python3_package_hash_algorithm
  hash_value              = var.automation_python3_package_hash_value
  tags                    = var.automation_python3_package_tags

  dynamic "timeouts" {
    for_each = var.automation_python3_package_timeouts == null ? [] : [var.automation_python3_package_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

