locals {
  private_endpoint_assignments = {
    for item in flatten([
      for endpoint_key, endpoint in var.private_endpoints : [
        for assignment_key, assignment in endpoint.role_assignments : {
          key           = jsonencode([endpoint_key, assignment_key])
          interface_key = jsonencode(["endpoint", endpoint_key, assignment_key])
          endpoint_key  = endpoint_key
          assignment    = assignment
        }
      ]
    ]) : item.key => item
  }
  # Every private endpoint, whichever of the two resources in main.private_endpoint.tf manages it.
  private_endpoint_resources = merge(azapi_resource.private_endpoints, azapi_resource.private_endpoints_unmanaged_dns_zone_groups)
  # The configuration of each private endpoint. It reproduces what the AzureRM provider sent, so that
  # upgrading moves the existing private endpoints without changing them.
  private_endpoints = {
    for key, endpoint in var.private_endpoints : key => {
      body = {
        properties = merge(
          {
            # Empty lists are sent rather than omitted, so that removing the last application security
            # group or IP configuration removes it from Azure.
            applicationSecurityGroups = [
              for asg_resource_id in values(endpoint.application_security_group_associations) : { id = asg_resource_id }
            ]
            ipConfigurations = [
              for ip_configuration in values(endpoint.ip_configurations) : {
                name = ip_configuration.name
                properties = {
                  groupId          = endpoint.subresource_name
                  memberName       = coalesce(ip_configuration.member_name, endpoint.subresource_name)
                  privateIPAddress = ip_configuration.private_ip_address
                }
              }
            ]
            privateLinkServiceConnections = [
              {
                name = coalesce(endpoint.private_service_connection_name, "pse-${var.name}")
                properties = {
                  groupIds             = [endpoint.subresource_name]
                  privateLinkServiceId = azapi_resource.this.id
                }
              }
            ]
            subnet = {
              id = endpoint.subnet_resource_id
            }
          },
          # Azure stores an unset custom network interface name as an empty string, so the property is
          # sent only when it is set. Sending null would report a difference on every plan.
          endpoint.network_interface_name == null ? {} : { customNetworkInterfaceName = endpoint.network_interface_name },
        )
      }
      location = coalesce(endpoint.location, var.location)
      name     = coalesce(endpoint.name, "pep-${var.name}")
      tags     = endpoint.tags != null ? endpoint.tags : var.tags
      # `resource_group_name` is a resource group in the automation account's subscription, as it was with the
      # AzureRM provider.
      parent_id = endpoint.resource_group_name == null ? var.parent_id : "/subscriptions/${local.subscription_id}/resourceGroups/${endpoint.resource_group_name}"
    }
  }
}
