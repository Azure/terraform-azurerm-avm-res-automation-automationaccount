mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test"
      output = {
        properties = {
          automationHybridServiceUrl = "https://automation.example.test"
          customDnsConfigs           = []
          networkInterfaces = [{
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg/providers/Microsoft.Network/networkInterfaces/endpoint-nic"
          }]
          vaultUri = "https://vault.example.test/"
        }
      }
    }
  }
  mock_data "azapi_resource" {
    defaults = {
      output = {
        private_ip_address = "10.0.0.4"
        properties         = { vaultUri = "https://vault.example.test/" }
      }
    }
  }
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
    defaults = { result = "11111111-1111-1111-1111-111111111111" }
  }
}

variables {
  name             = "automation-test"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg"
  sku              = { name = "Basic" }
  enable_telemetry = false
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
      lock = { kind = "ReadOnly", name = "endpoint-lock", notes = "Endpoint lock notes" }
      role_assignments = {
        named = {
          name                       = "22222222-2222-2222-2222-222222222222"
          role_definition_id_or_name = "reader"
          principal_id               = "33333333-3333-3333-3333-333333333333"
          description                = "Endpoint reader"
          principal_type             = "ServicePrincipal"
          condition                  = "true"
          condition_version          = "2.0"
        }
      }
    }
  }
}

run "defaults_create_no_endpoints" {
  command = apply
  variables {
    private_endpoints = {}
  }
  assert {
    condition     = length(output.private_endpoints) == 0 && length(azapi_resource.private_endpoint_role_assignments) == 0 && length(azapi_resource.private_endpoint_locks) == 0
    error_message = "No endpoints must create no endpoint extensions or outputs."
  }
  assert {
    condition     = azapi_resource.this.parent_id == var.parent_id && azapi_resource.this.body.properties.sku.name == "Basic"
    error_message = "The account must use its existing resource group and ARM SKU shape."
  }
}

run "preserves_unnamed_endpoint_role_guid_and_default_lock_name" {
  command = apply

  override_resource {
    target = random_uuid.private_endpoint_role_assignments["[\"existing\",\"reader\"]"]
    values = {
      result = "44444444-4444-4444-4444-444444444444"
    }
  }

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      existing = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "Webhook"
        lock               = { kind = "CanNotDelete" }
        role_assignments = {
          reader = {
            role_definition_id_or_name = "reader"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoint_role_assignments[jsonencode(["existing", "reader"])].name == "44444444-4444-4444-4444-444444444444" &&
      azapi_resource.private_endpoint_locks["existing"].name == "lock-CanNotDelete" &&
      azapi_resource.private_endpoint_locks["existing"].parent_id == azapi_resource.private_endpoints_unmanaged_dns_zone_groups["existing"].id
    )
    error_message = "Endpoint roles must retain their existing pair-keyed random GUID, and locks must retain their original address and default name in unmanaged DNS mode."
  }
}

run "managed_endpoint_preserves_configuration_and_output_shape" {
  command = apply
  assert {
    condition = (
      azapi_resource.private_endpoints["configured"].name == "endpoint-test" &&
      azapi_resource.private_endpoints["configured"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoint-rg" &&
      azapi_resource.private_endpoints["configured"].body.properties.subnet.id == var.private_endpoints.configured.subnet_resource_id &&
      azapi_resource.private_endpoints["configured"].body.properties.customNetworkInterfaceName == "endpoint-nic" &&
      azapi_resource.private_endpoints["configured"].tags.owner == "test" &&
      azapi_resource.private_dns_zone_groups["configured"].name == "dns-test" &&
      azapi_resource.private_dns_zone_groups["configured"].body.properties.privateDnsZoneConfigs[0].properties.privateDnsZoneId == one(var.private_endpoints.configured.private_dns_zone_resource_ids)
    )
    error_message = "The endpoint configuration and separate DNS-zone group must preserve consumer inputs."
  }
  assert {
    condition = alltrue([
      for ip in azapi_resource.private_endpoints["configured"].body.properties.ipConfigurations :
      ip.properties.memberName == (ip.name == "override" ? "custom-member" : "Webhook") &&
      ip.properties.groupId == "Webhook"
    ])
    error_message = "IP member names must preserve overrides and fall back to the endpoint subresource."
  }
  assert {
    condition = (
      output.private_endpoints.configured.id == azapi_resource.private_endpoints["configured"].id &&
      output.private_endpoints.configured.private_service_connection[0].name == "connection-test" &&
      output.private_endpoints.configured.private_service_connection[0].private_ip_address == "10.0.0.4" &&
      output.private_endpoints.configured.network_interface[0].name == "endpoint-nic" &&
      output.private_endpoints.configured.private_dns_zone_group[0].name == "dns-test" &&
      output.private_endpoints.configured.subnet_id == var.private_endpoints.configured.subnet_resource_id
    )
    error_message = "Legacy private endpoint output attributes must remain available."
  }
  assert {
    condition = (
      azapi_resource.private_endpoint_locks["configured"].body.properties.notes == "Endpoint lock notes" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].name == "22222222-2222-2222-2222-222222222222" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].body.properties.description == "Endpoint reader"
    )
    error_message = "Endpoint locks and role assignments must apply the standard interfaces."
  }
}

run "unmanaged_dns_keeps_endpoint_extensions" {
  command = apply
  variables {
    private_endpoints_manage_dns_zone_group = false
  }
  assert {
    condition = (
      length(azapi_resource.private_endpoints) == 0 &&
      length(azapi_resource.private_dns_zone_groups) == 0 &&
      length(azapi_resource.private_endpoints_unmanaged_dns_zone_groups) == 1 &&
      azapi_resource.private_endpoint_locks["configured"].parent_id == azapi_resource.private_endpoints_unmanaged_dns_zone_groups["configured"].id &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].parent_id == azapi_resource.private_endpoints_unmanaged_dns_zone_groups["configured"].id &&
      length(output.private_endpoints.configured.private_dns_zone_group) == 0
    )
    error_message = "External DNS management must not disable IP configuration, locks, RBAC or outputs."
  }
}

run "controls_and_standard_account_interfaces" {
  command = apply
  variables {
    lock = { kind = "CanNotDelete", notes = "Account notes" }
    role_assignments = {
      reader = {
        name                       = "55555555-5555-5555-5555-555555555555"
        role_definition_id_or_name = "Reader"
        principal_id               = "44444444-4444-4444-4444-444444444444"
      }
    }
    diagnostic_settings = {
      logs = {
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/log-rg/providers/Microsoft.OperationalInsights/workspaces/logs"
        logs                  = [{ category_group = "allLogs" }]
        metrics               = [{ category = "AllMetrics" }]
      }
    }
    retry               = { error_message_regex = ["ScopeLocked"], interval_seconds = 5, max_interval_seconds = 20 }
    timeouts            = { create = "45m", read = "10m", update = "40m", delete = "35m" }
    ignore_body_changes = { authorization_locks = ["properties.notes"] }
  }
  assert {
    condition = (
      azapi_resource.lock[0].body.properties.notes == "Account notes" &&
      azapi_resource.role_assignments["reader"].name == "55555555-5555-5555-5555-555555555555" &&
      azapi_resource.private_endpoint_locks["configured"].retry.interval_seconds == 5 &&
      azapi_resource.private_endpoint_role_assignments[jsonencode(["configured", "named"])].timeouts.delete == "35m" &&
      azapi_resource.diagnostic_settings["logs"].body.properties.logs[0].categoryGroup == "allLogs"
    )
    error_message = "Account interfaces and endpoint operation controls must be forwarded."
  }
}

run "versionless_cmk_uses_vault_uri_and_arm_key_source" {
  command = apply
  variables {
    private_endpoints = {}
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/key-rg/providers/Microsoft.KeyVault/vaults/vault"
      key_name              = "automation-key"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/key-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/encryption"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/key-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/encryption"]
    }
  }
  assert {
    condition = (
      azapi_resource.this.body.properties.encryption.keySource == "Microsoft.Keyvault" &&
      azapi_resource.this.body.properties.encryption.keyVaultProperties.keyvaultUri == "https://vault.example.test/" &&
      azapi_resource.this.body.properties.encryption.keyVaultProperties.keyVersion == null
    )
    error_message = "Canonical CMK must use the ARM enum and vault URI and leave versionless keys following rotations."
  }
}

run "missing_multiservice_subresource_is_rejected" {
  command = plan
  variables {
    private_endpoints = {
      missing = { subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet" }
    }
  }
  expect_failures = [var.private_endpoints]
}

run "invalid_subnet_resource_id_is_rejected" {
  command = plan
  variables {
    private_endpoints = {
      invalid = { subnet_resource_id = "/not-a-subnet", subresource_name = "Webhook" }
    }
  }
  expect_failures = [var.private_endpoints]
}

run "invalid_log_category_shape_is_rejected" {
  command = plan
  variables {
    private_endpoints = {}
    diagnostic_settings = {
      invalid = {
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/log-rg/providers/Microsoft.OperationalInsights/workspaces/logs"
        logs                  = [{ category = "JobLogs", category_group = "allLogs" }]
      }
    }
  }
  expect_failures = [var.diagnostic_settings]
}
