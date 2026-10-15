mock_provider "azurerm" {
  mock_resource "azurerm_automation_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test"
    }
  }
  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg/providers/Microsoft.Network/privateEndpoints/endpoint-test"
    }
  }
}

mock_provider "azapi" {
  mock_data "azapi_resource_list" {
    override_during = plan

    defaults = {
      output = {
        results = [{
          id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
          role_name = "Reader"
        }]
      }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-1111-1111-111111111111"
    }
  }
}

variables {
  name                = "automation-test"
  location            = "eastus"
  resource_group_name = "automation-rg"
  sku                 = "Basic"
  enable_telemetry    = false
  private_endpoints = {
    configured = {
      name                            = "endpoint-test"
      location                        = "westus2"
      resource_group_name             = "endpoint-rg"
      subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
      subresource_name                = "Webhook"
      network_interface_name          = "endpoint-nic"
      private_service_connection_name = "connection-test"
      private_dns_zone_group_name     = "dns-test"
      private_dns_zone_resource_ids   = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azure-automation.net"]
      tags                            = { owner = "test" }
      application_security_group_associations = {
        asg = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/applicationSecurityGroups/asg"
      }
      ip_configurations = {
        override = {
          name               = "override"
          private_ip_address = "10.0.0.4"
          member_name        = "custom-member"
        }
        fallback = {
          name               = "fallback"
          private_ip_address = "10.0.0.5"
        }
      }
      lock = {
        kind  = "ReadOnly"
        name  = "endpoint-lock"
        notes = "Endpoint lock notes"
      }
      role_assignments = {
        named = {
          name                                   = "22222222-2222-2222-2222-222222222222"
          role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
          principal_id                           = "33333333-3333-3333-3333-333333333333"
          description                            = "Endpoint reader"
          principal_type                         = "ServicePrincipal"
          condition                              = "true"
          condition_version                      = "2.0"
          delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
          skip_service_principal_aad_check       = true
        }
        generated = {
          role_definition_id_or_name = "Reader"
          principal_id               = "44444444-4444-4444-4444-444444444444"
          principal_type             = "Group"
        }
      }
    }
  }
}

run "defaults_create_no_endpoint_extensions" {
  command = apply

  variables {
    private_endpoints = {}
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 &&
      length(azurerm_private_endpoint_application_security_group_association.this) == 0 &&
      length(azapi_resource.private_endpoint_locks) == 0 &&
      length(azapi_resource.private_endpoint_role_assignments) == 0 &&
      length(random_uuid.private_endpoint_role_assignments) == 0 &&
      length(data.azapi_resource_list.private_endpoint_role_definitions) == 0 &&
      length(output.private_endpoints) == 0
    )
    error_message = "Omitted private endpoints must not create endpoints, locks, assignments or associations."
  }

  assert {
    condition = (
      azurerm_automation_account.this.name == "automation-test" &&
      azurerm_automation_account.this.location == "eastus" &&
      azurerm_automation_account.this.resource_group_name == "automation-rg" &&
      output.resource_id == azurerm_automation_account.this.id &&
      output.automation_account_id == azurerm_automation_account.this.id
    )
    error_message = "The Automation Account's existing address, inputs and outputs must remain intact."
  }
}

run "managed_dns_preserves_endpoint_configuration" {
  command = apply

  assert {
    condition = (
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 1 &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].name == "endpoint-test" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].location == "westus2" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].resource_group_name == "endpoint-rg" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].subnet_id == var.private_endpoints.configured.subnet_resource_id &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].custom_network_interface_name == "endpoint-nic" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].tags.owner == "test"
    )
    error_message = "Existing endpoint addresses and explicit location, group, subnet, NIC and tags must be preserved."
  }

  assert {
    condition = (
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].private_service_connection[0].name == "connection-test" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].private_service_connection[0].private_connection_resource_id == azurerm_automation_account.this.id &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].private_service_connection[0].subresource_names) == "Webhook" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].private_dns_zone_group[0].name == "dns-test" &&
      toset(azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].private_dns_zone_group[0].private_dns_zone_ids) == var.private_endpoints.configured.private_dns_zone_resource_ids
    )
    error_message = "The connection scope, subresource and authored DNS group must not change."
  }

  assert {
    condition = length(azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].ip_configuration) == 2 && alltrue([
      for ip in azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].ip_configuration :
      ip.member_name == (ip.name == "override" ? "custom-member" : "Webhook") &&
      ip.private_ip_address == (ip.name == "override" ? "10.0.0.4" : "10.0.0.5") &&
      ip.subresource_name == "Webhook"
    ])
    error_message = "Each managed endpoint IP must use its own member override, falling back to the endpoint's subresource."
  }

  assert {
    condition = (
      azurerm_private_endpoint_application_security_group_association.this["configured-asg"].private_endpoint_id == azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].id &&
      azurerm_private_endpoint_application_security_group_association.this["configured-asg"].application_security_group_id == var.private_endpoints.configured.application_security_group_associations.asg &&
      output.private_endpoints["configured"].id == azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].id
    )
    error_message = "Managed associations and the existing endpoint output must keep their original resource addresses and IDs."
  }
}

run "managed_dns_creates_complete_endpoint_extensions" {
  command = apply

  assert {
    condition = (
      length(azapi_resource.private_endpoint_locks) == 1 &&
      azapi_resource.private_endpoint_locks["configured"].name == "endpoint-lock" &&
      azapi_resource.private_endpoint_locks["configured"].parent_id == azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_locks["configured"].body.properties.level == "ReadOnly" &&
      azapi_resource.private_endpoint_locks["configured"].body.properties.notes == "Endpoint lock notes"
    )
    error_message = "The optional endpoint lock must preserve its name, level and notes and be scoped to the endpoint."
  }

  assert {
    condition = (
      length(azapi_resource.private_endpoint_role_assignments) == 2 &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].name == "22222222-2222-2222-2222-222222222222" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].parent_id == azurerm_private_endpoint.this_managed_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.principalId == "33333333-3333-3333-3333-333333333333" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.roleDefinitionId == var.private_endpoints.configured.role_assignments.named.role_definition_id_or_name &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.description == "Endpoint reader" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.condition == "true" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.conditionVersion == "2.0" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.delegatedManagedIdentityResourceId == var.private_endpoints.configured.role_assignments.named.delegated_managed_identity_resource_id
    )
    error_message = "Named endpoint role assignments must forward all supported properties without omission."
  }

  assert {
    condition = (
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "generated"])].name == "11111111-1111-1111-1111-111111111111" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "generated"])].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "generated"])].body.properties.principalType == "Group"
    )
    error_message = "Omitted role-assignment names must use stable UUID resources, and role names must resolve through the mocked definition lookup."
  }
}

run "unmanaged_dns_supports_ips_associations_and_extensions" {
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 1 &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].name == "endpoint-test" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].location == "westus2" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].resource_group_name == "endpoint-rg" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].private_service_connection[0].name == "connection-test" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].private_service_connection[0].private_connection_resource_id == azurerm_automation_account.this.id &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].private_dns_zone_group) == 0
    )
    error_message = "Unmanaged DNS must keep the existing endpoint address and connection without taking ownership of a DNS group."
  }

  assert {
    condition = length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].ip_configuration) == 2 && alltrue([
      for ip in azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].ip_configuration :
      ip.member_name == (ip.name == "override" ? "custom-member" : "Webhook") &&
      ip.private_ip_address == (ip.name == "override" ? "10.0.0.4" : "10.0.0.5") &&
      ip.subresource_name == "Webhook"
    ])
    error_message = "Unmanaged DNS endpoints must support the same per-IP member overrides and fallback."
  }

  assert {
    condition = (
      azurerm_private_endpoint_application_security_group_association.this["configured-asg"].private_endpoint_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_locks["configured"].parent_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].parent_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.description == "Endpoint reader" &&
      output.private_endpoints["configured"].id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["configured"].id
    )
    error_message = "Unmanaged DNS associations, locks, role assignments and outputs must all reference the unmanaged endpoint."
  }
}

run "minimal_endpoint_preserves_generated_defaults" {
  command = apply

  variables {
    private_endpoints = {
      minimal = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "DSCAndHybridWorker"
      }
    }
  }

  assert {
    condition = (
      azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].name == "pep-automation-test" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].location == "eastus" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].resource_group_name == "automation-rg" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].private_service_connection[0].name == "pse-automation-test" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].private_service_connection[0].subresource_names) == "DSCAndHybridWorker" &&
      length(azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].ip_configuration) == 0 &&
      length(azurerm_private_endpoint.this_managed_dns_zone_groups["minimal"].private_dns_zone_group) == 0 &&
      length(azapi_resource.private_endpoint_locks) == 0 &&
      length(azapi_resource.private_endpoint_role_assignments) == 0
    )
    error_message = "Omitted optional settings must preserve the original endpoint and connection defaults without adding extensions."
  }
}

run "optional_extension_fields_can_be_omitted" {
  command = apply

  variables {
    private_endpoints = {
      minimal = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        lock               = { kind = "CanNotDelete" }
        role_assignments = {
          reader = {
            role_definition_id_or_name = "Reader"
            principal_id               = "44444444-4444-4444-4444-444444444444"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoint_locks["minimal"].name == "lock-CanNotDelete" &&
      azapi_resource.private_endpoint_locks["minimal"].body.properties.notes == null &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["minimal", "reader"])].name == "11111111-1111-1111-1111-111111111111" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["minimal", "reader"])].body.properties.description == null &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["minimal", "reader"])].body.properties.principalType == null &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["minimal", "reader"])].body.properties.condition == null &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["minimal", "reader"])].body.properties.delegatedManagedIdentityResourceId == null
    )
    error_message = "Optional names, lock notes and role fields must remain optional with their documented defaults."
  }
}

run "none_lock_creates_no_lock" {
  command = apply

  variables {
    private_endpoints = {
      unlocked = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        lock               = { kind = "None" }
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoint_locks) == 0
    error_message = "The documented None lock setting must not create a lock."
  }
}

run "extension_resource_controls_are_forwarded" {
  command = apply

  variables {
    resource_types = {
      authorization_locks = "Microsoft.Authorization/locks@2016-09-01"
    }
    retry = {
      error_message_regex  = ["ScopeLocked"]
      interval_seconds     = 5
      max_interval_seconds = 20
    }
    timeouts = {
      create = "45m"
      read   = "10m"
      update = "40m"
      delete = "35m"
    }
    ignore_body_changes = {
      authorization_locks            = ["properties.notes"]
      authorization_role_assignments = ["properties.description"]
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoint_locks["configured"].type == "Microsoft.Authorization/locks@2016-09-01" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].type == "Microsoft.Authorization/roleAssignments@2022-04-01" &&
      azapi_resource.private_endpoint_locks["configured"].retry.interval_seconds == 5 &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].retry.max_interval_seconds == 20 &&
      azapi_resource.private_endpoint_locks["configured"].timeouts.create == "45m" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].timeouts.delete == "35m"
    )
    error_message = "AzAPI type, retry and timeout controls must reach both endpoint extension resources."
  }
}

run "arbitrary_role_assignment_keys_do_not_collide" {
  command = apply

  override_resource {
    target = azurerm_private_endpoint.this_managed_dns_zone_groups["a-b"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg/providers/Microsoft.Network/privateEndpoints/endpoint-one"
    }
  }

  override_resource {
    target = azurerm_private_endpoint.this_managed_dns_zone_groups["a"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg/providers/Microsoft.Network/privateEndpoints/endpoint-two"
    }
  }

  variables {
    private_endpoints = {
      a-b = {
        name               = "endpoint-one"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        role_assignments = {
          c = {
            role_definition_id_or_name = "Reader"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
      a = {
        name               = "endpoint-two"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "DSCAndHybridWorker"
        role_assignments = {
          b-c = {
            role_definition_id_or_name = "Reader"
            principal_id               = "44444444-4444-4444-4444-444444444444"
          }
        }
      }
    }
  }

  assert {
    condition = (
      length(azapi_resource.private_endpoint_role_assignments) == 2 &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["a-b", "c"])].body.properties.principalId == "33333333-3333-3333-3333-333333333333" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["a", "b-c"])].body.properties.principalId == "44444444-4444-4444-4444-444444444444" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["a-b", "c"])].parent_id == azurerm_private_endpoint.this_managed_dns_zone_groups["a-b"].id &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["a", "b-c"])].parent_id == azurerm_private_endpoint.this_managed_dns_zone_groups["a"].id
    )
    error_message = "Private endpoint and role map keys must remain independently identifiable."
  }
}

run "invalid_subnet_id_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "not-a-subnet-resource-id"
        subresource_name   = "Webhook"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_private_dns_zone_id_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name              = "Webhook"
        private_dns_zone_resource_ids = ["not-a-dns-zone-resource-id"]
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_application_security_group_id_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        application_security_group_associations = {
          invalid = "not-an-application-security-group-resource-id"
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_delegated_identity_id_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        role_assignments = {
          reader = {
            role_definition_id_or_name             = "Reader"
            principal_id                           = "33333333-3333-3333-3333-333333333333"
            delegated_managed_identity_resource_id = "not-an-identity-resource-id"
          }
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "missing_subresource_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "unknown_role_name_is_rejected" {
  command = plan

  override_resource {
    target          = azurerm_private_endpoint.this_managed_dns_zone_groups["invalid"]
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg/providers/Microsoft.Network/privateEndpoints/invalid"
    }
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        role_assignments = {
          reader = {
            role_definition_id_or_name = "Role that does not exist"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoint_role_assignments]
}

run "invalid_lock_kind_is_rejected" {
  command = plan

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        lock               = { kind = "Invalid" }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}
