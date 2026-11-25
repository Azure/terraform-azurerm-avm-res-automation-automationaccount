# The private endpoints are split across two resources because each one is the destination of a `moved`
# block from its AzureRM counterpart, and Terraform allows only one source per destination. The two are
# configured identically: the private DNS zone group is a separate child resource in AzAPI, so the
# private endpoint itself no longer differs between the modes.

# The private endpoints when the module manages their private DNS zone groups.
resource "azapi_resource" "private_endpoints" {
  for_each = { for key, endpoint in local.private_endpoints : key => endpoint if var.private_endpoints_manage_dns_zone_group }

  location               = each.value.location
  name                   = each.value.name
  parent_id              = each.value.parent_id
  type                   = var.resource_types.network_private_endpoints
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints) > 0 ? var.ignore_body_changes.network_private_endpoints : null
  response_export_values = ["properties.customDnsConfigs", "properties.networkInterfaces"]
  retry                  = var.retry
  tags                   = each.value.tags

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
    ignore_changes = [name]
  }
}

moved {
  from = azurerm_private_endpoint.this_managed_dns_zone_groups
  to   = azapi_resource.private_endpoints
}

# The private endpoints when their private DNS zone groups are managed elsewhere, for example by Azure
# Policy.
resource "azapi_resource" "private_endpoints_unmanaged_dns_zone_groups" {
  for_each = { for key, endpoint in local.private_endpoints : key => endpoint if !var.private_endpoints_manage_dns_zone_group }

  location               = each.value.location
  name                   = each.value.name
  parent_id              = each.value.parent_id
  type                   = var.resource_types.network_private_endpoints
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints) > 0 ? var.ignore_body_changes.network_private_endpoints : null
  response_export_values = ["properties.customDnsConfigs", "properties.networkInterfaces"]
  retry                  = var.retry
  tags                   = each.value.tags

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
    ignore_changes = [name]
  }
}

moved {
  from = azurerm_private_endpoint.this_unmanaged_dns_zone_groups
  to   = azapi_resource.private_endpoints_unmanaged_dns_zone_groups
}

# Application security groups are part of the private endpoint's body from this version. The
# association resources the AzureRM provider used are dropped from the state without being deleted, so
# the private endpoints keep their application security groups.
removed {
  from = azurerm_private_endpoint_application_security_group_association.this

  lifecycle {
    destroy = false
  }
}

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = { for key, endpoint in var.private_endpoints : key => endpoint if var.private_endpoints_manage_dns_zone_group && length(endpoint.private_dns_zone_resource_ids) > 0 }

  name      = each.value.private_dns_zone_group_name
  parent_id = azapi_resource.private_endpoints[each.key].id
  type      = var.resource_types.network_private_endpoints_private_dns_zone_groups
  body = {
    properties = {
      # Each configuration is named after its zone, as the AzureRM provider named them.
      privateDnsZoneConfigs = [
        for private_dns_zone_resource_id in each.value.private_dns_zone_resource_ids : {
          name = provider::azapi::parse_resource_id("Microsoft.Network/privateDnsZones", private_dns_zone_resource_id).name
          properties = {
            privateDnsZoneId = private_dns_zone_resource_id
          }
        }
      ]
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups) > 0 ? var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# The AzureRM provider read each private endpoint's private IP address from its network interface. The
# private endpoint reports the address itself only when it is not linked to a private DNS zone, so the
# network interface is read here as well.
data "azapi_resource" "private_endpoint_network_interfaces" {
  for_each = local.private_endpoint_resources

  resource_id = each.value.output.properties.networkInterfaces[0].id
  type        = "Microsoft.Network/networkInterfaces@2025-05-01"
  response_export_values = {
    private_ip_address = "properties.ipConfigurations[0].properties.privateIPAddress"
  }
}

# Keep the existing lock address and name in both DNS-management modes.
resource "azapi_resource" "private_endpoint_locks" {
  for_each = { for key, endpoint in var.private_endpoints : key => endpoint if endpoint.lock != null }

  name      = coalesce(each.value.lock.name, "lock-${each.value.lock.kind}")
  parent_id = local.private_endpoint_resources[each.key].id
  type      = var.resource_types.authorization_locks
  body = {
    # Notes are sent only when they are set, which is how the AzureRM provider left the locks it created.
    properties = merge(
      { level = each.value.lock.kind },
      each.value.lock.notes == null ? {} : { notes = each.value.lock.notes },
    )
  }
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # Create the locks last and remove them first. A ReadOnly lock blocks changes to the private endpoint
  # and its DNS zone group.
  depends_on = [azapi_resource.private_dns_zone_groups, azapi_resource.private_endpoint_role_assignments]
}

resource "random_uuid" "private_endpoint_role_assignments" {
  for_each = local.private_endpoint_assignments
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = local.private_endpoint_assignments

  name                   = module.avm_interfaces.role_assignments_azapi[each.value.interface_key].name
  parent_id              = local.private_endpoint_resources[each.value.endpoint_key].id
  type                   = var.resource_types.authorization_role_assignments
  body                   = module.avm_interfaces.role_assignments_azapi[each.value.interface_key].body
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  ignore_casing          = true
  ignore_null_property   = true
  replace_triggers_refs  = ["properties.principalId", "properties.roleDefinitionId", "properties.delegatedManagedIdentityResourceId"]
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = strcontains(lower(local.role_assignments[each.value.interface_key].role_definition_id_or_name), local.role_definition_resource_substring)
      error_message = "The private endpoint role definition was not found. Supply a role definition available at the parent scope, or its resource ID."
    }
  }
}
