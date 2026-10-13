locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  private_endpoints = merge(
    azurerm_private_endpoint.this_managed_dns_zone_groups,
    azurerm_private_endpoint.this_unmanaged_dns_zone_groups,
  )
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  private_endpoint_role_assignments = {
    for assignment in flatten([
      for pe_key, endpoint in var.private_endpoints : [
        for assignment_key, assignment in endpoint.role_assignments : {
          pe_key         = pe_key
          assignment_key = assignment_key
          assignment     = assignment
        }
      ]
    ]) : jsonencode([assignment.pe_key, assignment.assignment_key]) => assignment
  }
  private_endpoint_role_definition_names = {
    for key, definitions in data.azapi_resource_list.private_endpoint_role_definitions : key => {
      for definition in definitions.output.results : definition.role_name => definition.id
    }
  }
  private_endpoint_role_definition_ids = {
    for key, assignment in local.private_endpoint_role_assignments : key => (
      can(provider::azapi::parse_resource_id("Microsoft.Authorization/roleDefinitions", assignment.assignment.role_definition_id_or_name)) ?
      assignment.assignment.role_definition_id_or_name :
      lookup(local.private_endpoint_role_definition_names[assignment.pe_key], assignment.assignment.role_definition_id_or_name, null)
    )
  }
  role_definition_resource_substring = "providers/Microsoft.Authorization/roleDefinitions"
}
