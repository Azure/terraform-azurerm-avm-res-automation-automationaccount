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

run "optional_runbook_objects" {
  command = apply

  variables {
    automation_runbooks = {
      published = {
        name                 = "published"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/runbook.ps1" }
      }
      draft = {
        name         = "draft"
        runbook_type = "PowerShell"
        log_progress = false
        log_verbose  = false
        draft        = {}
      }
      parameters = {
        name         = "parameters"
        runbook_type = "PowerShell"
        log_progress = false
        log_verbose  = false
        draft = {
          parameters = [{
            key       = "resourcegroup"
            type      = "string"
            mandatory = true
          }]
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.automation_account_runbooks["published"].body.properties.draft == null &&
      azapi_resource.automation_account_runbooks["published"].body.properties.publishContentLink.contentHash == null &&
      azapi_resource.automation_account_runbooks["draft"].body.properties.draft.draftContentLink == null &&
      azapi_resource.automation_account_runbooks["draft"].body.properties.draft.parameters == null &&
      azapi_resource.automation_account_runbooks["parameters"].body.properties.draft.parameters.resourcegroup.isMandatory
    )
    error_message = "Omitted nested draft objects must remain optional, and parameters must use their declared keys rather than list indexes."
  }
}

run "rejects_unsupported_inline_content" {
  command = plan

  variables {
    automation_runbooks = {
      inline = {
        name         = "inline"
        runbook_type = "PowerShell"
        log_progress = false
        log_verbose  = false
        content      = "Write-Output 'test'"
      }
    }
  }

  expect_failures = [var.automation_runbooks]
}

run "escapes_string_variables_and_omits_absent_hashes" {
  command = apply

  variables {
    automation_variable_strings = {
      escaped   = { name = "escaped", value = "line 1\n\"quoted\"\\path" }
      omitted   = { name = "omitted" }
      encrypted = { name = "encrypted", value = "test-only", encrypted = true, value_version = 2 }
    }
    automation_modules = {
      module = { name = "module", content_uri = "https://example.com/module.zip" }
    }
  }

  assert {
    condition = (
      jsondecode(azapi_resource.automation_account_variable_strings["escaped"].body.properties.value) == "line 1\n\"quoted\"\\path" &&
      azapi_resource.automation_account_variable_strings["omitted"].body.properties.value == null &&
      azapi_resource.automation_account_variable_strings["encrypted"].body.properties.value == null &&
      azapi_resource.automation_account_modules["module"].body.properties.contentLink.contentHash == null
    )
    error_message = "String variables must remain valid JSON, omitted and encrypted values must stay out of the public body, and absent module hashes must not become empty objects."
  }
}

run "rejects_partial_module_hash" {
  command = plan

  variables {
    automation_modules = {
      module = {
        name           = "module"
        content_uri    = "https://example.com/module.zip"
        hash_algorithm = "sha256"
      }
    }
  }

  expect_failures = [azapi_resource.automation_account_modules]
}

run "encrypted_variable_types_omit_public_values" {
  command = apply

  variables {
    automation_variable_bools = {
      encrypted = { name = "bool", value = false, encrypted = true }
    }
    automation_variable_datetimes = {
      encrypted = { name = "date", value = "2027-01-01T00:00:00Z", encrypted = true }
    }
    automation_variable_ints = {
      encrypted = { name = "int", value = 42, encrypted = true }
    }
    automation_variable_objects = {
      encrypted = { name = "object", value = "{\"key\":\"test-only\"}", encrypted = true }
    }
  }

  assert {
    condition = (
      azapi_resource.automation_account_variable_bools["encrypted"].body.properties.value == null &&
      azapi_resource.automation_account_variable_datetimes["encrypted"].body.properties.value == null &&
      azapi_resource.automation_account_variable_ints["encrypted"].body.properties.value == null &&
      azapi_resource.automation_account_variable_objects["encrypted"].body.properties.value == null
    )
    error_message = "Encrypted values of every supported type must be kept out of persistent public Automation resource bodies."
  }
}

run "rejects_invalid_encrypted_variable_version" {
  command = plan

  variables {
    automation_variable_strings = {
      encrypted = { name = "encrypted", value = "test-only", encrypted = true, value_version = 1.5 }
    }
  }

  expect_failures = [azapi_resource.automation_account_variable_strings]
}

run "separates_write_only_payloads" {
  command = apply

  variables {
    automation_credentials = {
      credential = { name = "credential", username = "test", password = "test-only", password_version = 2 }
    }
    automation_certificates = {
      certificate = { name = "certificate", base64 = "dGVzdA==", base64_version = 3 }
    }
    automation_source_controls = {
      source = {
        name                   = "source"
        folder_path            = "/"
        repository_url         = "https://example.com/repo.git"
        source_control_type    = "GitHub"
        branch                 = "main"
        security_token_version = 4
        security               = { token = "test-only", token_type = "Oauth" }
      }
    }
  }

  assert {
    condition = (
      !contains(keys(azapi_resource.automation_accounts_credential["credential"].body.properties), "password") &&
      !contains(keys(azapi_resource.automation_account_certificates["certificate"].body.properties), "base64Value") &&
      !contains(keys(azapi_resource.automation_account_source_controls["source"].body.properties), "securityToken")
    )
    error_message = "Passwords, certificate contents and source-control tokens must not appear in persistent resource bodies."
  }
}

run "generated_and_supplied_webhook_uris" {
  command = apply

  override_resource {
    target = azapi_resource_action.automation_webhook_uris["generated"]
    values = {
      sensitive_output = { uri = "https://example.com/generated-test-only" }
    }
  }

  variables {
    automation_runbooks = {
      runbook = {
        name                 = "runbook"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/runbook.ps1" }
      }
    }
    automation_webhooks = {
      generated = {
        name        = "generated"
        expiry_time = "2030-01-01T00:00:00Z"
        runbook_key = "runbook"
      }
      supplied = {
        name        = "supplied"
        expiry_time = "2030-01-01T00:00:00Z"
        runbook_key = "runbook"
        uri         = "https://example.com/supplied-test-only"
      }
    }
  }

  assert {
    condition = (
      length(azapi_resource_action.automation_webhook_uris) == 1 &&
      output.automation_webhook_uris["generated"] == "https://example.com/generated-test-only" &&
      output.automation_webhook_uris["supplied"] == "https://example.com/supplied-test-only" &&
      !contains(keys(azapi_resource.automation_account_webhooks["generated"].body.properties), "uri")
    )
    error_message = "Only omitted URIs must be generated; both URI paths must produce sensitive outputs rather than persistent public request fields."
  }
}

run "rejects_invalid_secret_versions_and_token_type" {
  command = plan

  variables {
    automation_credentials = {
      credential = { name = "credential", username = "test", password = "test-only", password_version = 0 }
    }
    automation_certificates = {
      certificate = { name = "certificate", base64 = "dGVzdA==", base64_version = 1.5 }
    }
    automation_source_controls = {
      source = {
        name                   = "source"
        folder_path            = "/"
        repository_url         = "https://example.com/repo.git"
        source_control_type    = "GitHub"
        branch                 = "main"
        security_token_version = -1
        security               = { token = "test-only", token_type = "invalid" }
      }
    }
  }

  expect_failures = [var.automation_credentials, var.automation_certificates, var.automation_source_controls]
}
