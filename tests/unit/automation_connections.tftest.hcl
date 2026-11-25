mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "random" {}
mock_provider "time" {}

override_resource {
  target = azapi_resource.this
  values = {
    id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test"
    output = { properties = { automationHybridServiceUrl = "https://example.com/hybrid" } }
  }
}

variables {
  name             = "automation-test"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg"
  sku              = { name = "Basic" }
  enable_telemetry = false
}

run "consolidates_all_connection_types" {
  command = apply

  variables {
    timeouts = { create = "40m" }
    retry = {
      error_message_regex = ["Conflict"]
      interval_seconds    = 5
    }
    automation_connections = {
      custom = {
        name        = "custom"
        type        = "CustomConnection"
        values      = { endpoint = "https://example.com" }
        description = "Custom connection"
      }
      certificate = {
        name     = "certificate"
        type     = "Azure"
        values   = { SubscriptionID = "overridden" }
        timeouts = { create = "10m" }
      }
      principal = {
        name   = "principal"
        type   = "AzureServicePrincipal"
        values = {}
      }
      classic = {
        name   = "classic"
        type   = "AzureClassicCertificate"
        values = {}
      }
    }
    automation_connection_certificates = {
      certificate = {
        connection_key              = "certificate"
        automation_certificate_name = "automation-cert"
        subscription_id             = "11111111-1111-1111-1111-111111111111"
      }
    }
    automation_connection_service_principals = {
      principal = {
        connection_key         = "principal"
        application_id         = "22222222-2222-2222-2222-222222222222"
        certificate_thumbprint = "ABCDEF"
        subscription_id        = "11111111-1111-1111-1111-111111111111"
        tenant_id              = "33333333-3333-3333-3333-333333333333"
      }
    }
    automation_connection_classic_certificates = {
      classic = {
        connection_key         = "classic"
        certificate_asset_name = "classic-cert"
        subscription_id        = "11111111-1111-1111-1111-111111111111"
        subscription_name      = "Example subscription"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.automation_account_connections) == 4
    error_message = "Each generic connection must have exactly one ARM resource."
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["custom"].body.properties.fieldDefinitionValues.endpoint == "https://example.com" &&
      azapi_resource.automation_account_connections["custom"].body.properties.connectionType.name == "CustomConnection" &&
      azapi_resource.automation_account_connections["custom"].body.properties.description == "Custom connection" &&
      azapi_resource.automation_account_connections["custom"].parent_id == azapi_resource.this.id
    )
    error_message = "Custom connections must preserve their fields, description, type, and parent."
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["certificate"].body.properties.fieldDefinitionValues.AutomationCertificateName == "automation-cert" &&
      azapi_resource.automation_account_connections["certificate"].body.properties.fieldDefinitionValues.SubscriptionID == "11111111-1111-1111-1111-111111111111" &&
      length(keys(azapi_resource.automation_account_connections["certificate"].body.properties.fieldDefinitionValues)) == 2
    )
    error_message = "Azure certificate fields must use the required casing and override generic values."
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["principal"].body.properties.fieldDefinitionValues.ApplicationId == "22222222-2222-2222-2222-222222222222" &&
      azapi_resource.automation_account_connections["principal"].body.properties.fieldDefinitionValues.CertificateThumbprint == "ABCDEF" &&
      azapi_resource.automation_account_connections["principal"].body.properties.fieldDefinitionValues.SubscriptionId == "11111111-1111-1111-1111-111111111111" &&
      azapi_resource.automation_account_connections["principal"].body.properties.fieldDefinitionValues.TenantId == "33333333-3333-3333-3333-333333333333"
    )
    error_message = "Service principal fields must map to the ARM connection field names."
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["classic"].body.properties.fieldDefinitionValues.CertificateAssetName == "classic-cert" &&
      azapi_resource.automation_account_connections["classic"].body.properties.fieldDefinitionValues.SubscriptionId == "11111111-1111-1111-1111-111111111111" &&
      azapi_resource.automation_account_connections["classic"].body.properties.fieldDefinitionValues.SubscriptionName == "Example subscription"
    )
    error_message = "Classic certificate fields must map to the ARM connection field names."
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["custom"].timeouts.create == "40m" &&
      azapi_resource.automation_account_connections["certificate"].timeouts.create == "10m" &&
      azapi_resource.automation_account_connections["custom"].retry.interval_seconds == 5
    )
    error_message = "Per-connection timeouts must override module defaults and retries must propagate."
  }
}

run "preserves_generic_builtin_connection" {
  command = apply

  variables {
    automation_connections = {
      certificate = {
        name = "certificate"
        type = "Azure"
        values = {
          AutomationCertificateName = "cert"
          SubscriptionID            = "11111111-1111-1111-1111-111111111111"
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.automation_account_connections["certificate"].body.properties.fieldDefinitionValues.AutomationCertificateName == "cert" &&
      azapi_resource.automation_account_connections["certificate"].body.properties.fieldDefinitionValues.SubscriptionID == "11111111-1111-1111-1111-111111111111"
    )
    error_message = "Built-in connections must also work without specialized entries."
  }
}

run "empty_connections" {
  command = apply

  assert {
    condition     = length(azapi_resource.automation_account_connections) == 0
    error_message = "Empty inputs must create no connections."
  }
}

run "rejects_unknown_connection_key" {
  command = plan

  variables {
    automation_connection_certificates = {
      missing = {
        connection_key              = "missing"
        automation_certificate_name = "cert"
        subscription_id             = "11111111-1111-1111-1111-111111111111"
      }
    }
  }

  expect_failures = [var.automation_connections]
}

run "rejects_mismatched_specialization" {
  command = plan

  variables {
    automation_connections = {
      custom = {
        name   = "custom"
        type   = "CustomConnection"
        values = {}
      }
    }
    automation_connection_certificates = {
      certificate = {
        connection_key              = "custom"
        automation_certificate_name = "cert"
        subscription_id             = "11111111-1111-1111-1111-111111111111"
      }
    }
  }

  expect_failures = [var.automation_connections]
}

run "rejects_duplicate_specializations" {
  command = plan

  variables {
    automation_connections = {
      certificate = {
        name   = "certificate"
        type   = "Azure"
        values = {}
      }
    }
    automation_connection_certificates = {
      first = {
        connection_key              = "certificate"
        automation_certificate_name = "cert"
        subscription_id             = "11111111-1111-1111-1111-111111111111"
      }
      second = {
        connection_key              = "certificate"
        automation_certificate_name = "other-cert"
        subscription_id             = "11111111-1111-1111-1111-111111111111"
      }
    }
  }

  expect_failures = [var.automation_connections]
}

run "rejects_missing_builtin_fields" {
  command = plan

  variables {
    automation_connections = {
      principal = {
        name   = "principal"
        type   = "AzureServicePrincipal"
        values = {}
      }
    }
  }

  expect_failures = [azapi_resource.automation_account_connections]
}
