locals {
  customer_managed_encryption     = var.customer_managed_key != null || var.encryption.key_source == "Microsoft.KeyVault"
  encryption_identity_resource_id = var.customer_managed_key != null ? try(var.customer_managed_key.user_assigned_identity.resource_id, null) : var.encryption.user_assigned_identity_id
  encryption_key_name             = var.customer_managed_key != null ? var.customer_managed_key.key_name : try(split("/", var.encryption.key_vault_key_id)[4], null)
  encryption_key_version          = var.customer_managed_key != null ? var.customer_managed_key.key_version : try(split("/", var.encryption.key_vault_key_id)[5], null)
  encryption_vault_uri            = var.customer_managed_key != null ? data.azapi_resource.encryption_key_vault[0].output.properties.vaultUri : try("https://${split("/", var.encryption.key_vault_key_id)[2]}", null)
  all_role_assignments = merge(
    { for key, assignment in var.role_assignments : jsonencode(["root", key]) => assignment },
    {
      for key, assignment in local.private_endpoint_assignments : assignment.interface_key => merge(assignment.assignment, {
        name = assignment.assignment.name != null ? assignment.assignment.name : random_uuid.private_endpoint_role_assignments[key].result
      })
    },
  )
  # Role names are matched case-insensitively, as the AzureRM provider matched them.
  role_definition_ids_by_name = length(local.all_role_assignments) > 0 ? {
    for definition in data.azapi_resource_list.role_definitions[0].output.results : lower(definition.role_name) => definition.id...
  } : {}
  role_definition_resource_substring = "/providers/microsoft.authorization/roledefinitions/"
  role_assignments = {
    for key, assignment in local.all_role_assignments : key => merge(assignment, {
      # The AzureRM provider sent this principal type when the flag was set, which skips the Entra ID
      # existence check that fails for newly created service principals.
      principal_type = assignment.principal_type == null && assignment.skip_service_principal_aad_check ? "ServicePrincipal" : assignment.principal_type
      # Names resolve to IDs. Tenant-level IDs are qualified with the subscription, which is the form
      # Azure returns, so that the configuration and the deployed assignment compare equal.
      role_definition_id_or_name = (
        !strcontains(lower(assignment.role_definition_id_or_name), local.role_definition_resource_substring) ? try(local.role_definition_ids_by_name[lower(assignment.role_definition_id_or_name)][0], assignment.role_definition_id_or_name) :
        startswith(lower(assignment.role_definition_id_or_name), "/providers/") ? "/subscriptions/${local.subscription_id}${assignment.role_definition_id_or_name}" :
        assignment.role_definition_id_or_name
      )
    })
  }
  subscription_id = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).subscription_id

}
