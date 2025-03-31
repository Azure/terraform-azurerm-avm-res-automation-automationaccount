<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Resources

The following resources are used by this module:

- [azurerm_automation_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) (resource)
- [azurerm_automation_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_certificate) (resource)
- [azurerm_automation_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_connection) (resource)
- [azurerm_automation_connection_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_connection_certificate) (resource)
- [azurerm_automation_connection_classic_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_connection_classic_certificate) (resource)
- [azurerm_automation_connection_service_principal.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_connection_service_principal) (resource)
- [azurerm_automation_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) (resource)
- [azurerm_automation_hybrid_runbook_worker.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_hybrid_runbook_worker) (resource)
- [azurerm_automation_hybrid_runbook_worker_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_hybrid_runbook_worker_group) (resource)
- [azurerm_automation_module.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_module) (resource)
- [azurerm_automation_powershell72_module.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_powershell72_module) (resource)
- [azurerm_automation_python3_package.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_python3_package) (resource)
- [azurerm_automation_runbook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) (resource)
- [azurerm_automation_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) (resource)
- [azurerm_automation_source_control.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_source_control) (resource)
- [azurerm_automation_variable_bool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_bool) (resource)
- [azurerm_automation_variable_datetime.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_datetime) (resource)
- [azurerm_automation_variable_int.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_int) (resource)
- [azurerm_automation_variable_object.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_object) (resource)
- [azurerm_automation_variable_string.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) (resource)
- [azurerm_automation_watcher.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_watcher) (resource)
- [azurerm_automation_webhook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_webhook) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this_managed_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [random_uuid.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure location where the resources will be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Automation Account.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the Automation Account. Possible values are Basic and Free

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_automation_certificates"></a> [automation\_certificates](#input\_automation\_certificates)

Description: A list of Automation Certificates which should be created in this Automation Account.
  `name` - (Required) The name of the Certificate.
  `base64` - (Required) The base64 encoded value of the Certificate.
  `description` - (Optional) A description for this Certificate.
  `exportable` - (Optional) Whether the Certificate is exportable. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:

```terraform
automation_certificates = {
  "mycert" = {
    name        = "mycert"
    base64      = "base64encodedvalue"
    description = "My Certificate"
    exportable  = true
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    base64      = string
    description = optional(string)
    exportable  = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_connection_certificates"></a> [automation\_connection\_certificates](#input\_automation\_connection\_certificates)

Description: A list of Automation Connection Certificates which should be created in this Automation Account.
  `connection_key` - (Required) The key of the Connection to use for this Connection Certificate.
  `subscription_id` - (Required) The Subscription ID to use for this Connection Certificate.
  `automation_certificate_name` - (Required) The name of the Automation Certificate to use for this Connection Certificate.

Example Input:

```terraform
automation_connection_certificates = {
  "myconnection" = {
    connection_key              = "myconnection"
    subscription_id             = "12345678-1234-1234-1234-123456789012"
    automation_certificate_name = "mycert"
  }
}
```

Type:

```hcl
map(object({
    connection_key              = string
    subscription_id             = string
    automation_certificate_name = string
  }))
```

Default: `{}`

### <a name="input_automation_connection_classic_certificates"></a> [automation\_connection\_classic\_certificates](#input\_automation\_connection\_classic\_certificates)

Description: A list of Automation Connection Classic Certificates which should be created in this Automation Account.
  `connection_key` - (Required) The key of the Connection to use for this Connection Classic Certificate.
  `subscription_id` - (Required) The Subscription ID to use for this Connection Classic Certificate.
  `subscription_name` - (Required) The Subscription Name to use for this Connection Classic Certificate.
  `certificate_asset_name` - (Required) The name of the certificate asset to use for this Connection Classic Certificate.

Example Input:
```terraform
automation_connection_classic_certificates = {
  "myconnection" = {
    connection_key         = "myconnection"
    subscription_id        = "12345678-1234-1234-1234-123456789012"
    subscription_name      = "My Subscription"
    certificate_asset_name = "mycert"
  }
}
```

Type:

```hcl
map(object({
    connection_key         = string
    subscription_id        = string
    subscription_name      = string
    certificate_asset_name = string
  }))
```

Default: `{}`

### <a name="input_automation_connection_service_principals"></a> [automation\_connection\_service\_principals](#input\_automation\_connection\_service\_principals)

Description: A list of Automation Connection Service Principals which should be created in this Automation Account.
  `connection_key` - (Required) The key of the Connection to use for this Connection Service Principal.
  `tenant_id` - (Required) The Tenant ID to use for this Connection Service Principal.
  `application_id` - (Required) The Application ID to use for this Connection Service Principal.
  `certificate_thumbprint` - (Required) The Certificate Thumbprint to use for this Connection Service Principal.
  `subscription_id` - (Required) The Subscription ID to use for this Connection Service Principal.

Example Input:
```terraform
automation_connection_service_principals = {
  "myconnection" = {
    connection_key         = "myconnection"
    tenant_id              = "12345678-1234-1234-1234-123456789012"
    application_id         = "12345678-1234-1234-1234-123456789012"
    certificate_thumbprint = "1234567890abcdef"
    subscription_id        = "12345678-1234-1234-1234-123456789012"
  }
}
```

Type:

```hcl
map(object({
    connection_key         = string
    tenant_id              = string
    application_id         = string
    certificate_thumbprint = string
    subscription_id        = string
  }))
```

Default: `{}`

### <a name="input_automation_connections"></a> [automation\_connections](#input\_automation\_connections)

Description: A list of Automation Connections which should be created in this Automation Account.
  `name` - (Required) The name of the Connection.
  `type` - (Required) The type of the Connection.
  `values` - (Required) A mapping of key value pairs passed to the connection. Different `type` needs different parameters in the `values`. Builtin types have required field values as below:
    `Azure`: parameters `AutomationCertificateName` and `SubscriptionID`.
    `AzureServicePrincipal`: parameters `TenantID`, `ApplicationID`, and `CertificateThumbprint`.
    `AzureClassicCertificate`: parameters `SubscriptionID`, `SubscriptionName`, and `CertificateAsserName`.
  `description` - (Optional) A description for this Connection.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_connections = {
  "myconnection" = {
    name        = "myconnection"
    type        = "Azure"
    values      = {
      AutomationCertificateName = "mycert"
      SubscriptionID            = "12345678-1234-1234-1234-123456789012"
    }
    description = "My Connection"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    type        = string
    values      = map(string)
    description = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_credentials"></a> [automation\_credentials](#input\_automation\_credentials)

Description: A list of Automation Credentials which should be created in this Automation Account.
  `name` - (Required) The name of the Credential.
  `username` - (Required) The username associated with this Automation Credential.
  `password` - (Required) The password associated with this Automation Credential.
  `description` - (Optional) A description associated with this Automation Credential.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_credentials = {
  "mycredential" = {
    name        = "mycredential"
    username    = "myusername"
    password    = "mypassword"
    description = "My Credential"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    username    = string
    password    = string
    description = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_hybrid_runbook_worker_groups"></a> [automation\_hybrid\_runbook\_worker\_groups](#input\_automation\_hybrid\_runbook\_worker\_groups)

Description: A list of Hybrid Runbook Worker Groups which should be created in this Automation Account.
  `name` - (Required) The name of the Hybrid Runbook Worker Group.
  `credential_name` - (Optional) The name of resource type azurerm\_automation\_credential to use for hybrid worker.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_hybrid_runbook_worker_groups = {
  "mygroup" = {
    name            = "mygroup"
    credential_name = "mycredential"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name            = string
    credential_name = optional(string, null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_hybrid_runbook_workers"></a> [automation\_hybrid\_runbook\_workers](#input\_automation\_hybrid\_runbook\_workers)

Description: A list of Hybrid Runbook Workers which should be created in this Automation Account.
  `Hybrid_worker_group_key` - (Required) The key of the Hybrid Runbook Worker Group to which this Hybrid Runbook Worker belongs.
  `vm_resource_id` - (Required) The Resource ID of the Virtual Machine to use as a Hybrid Runbook Worker.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_hybrid_runbook_workers = {
  "myworker" = {
    hybrid_worker_group_key = "mygroup"
    vm_resource_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/mygroup/providers/Microsoft.Compute/virtualMachines/myvm"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    hybrid_worker_group_key = string
    vm_resource_id          = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_modules"></a> [automation\_modules](#input\_automation\_modules)

Description: A list of Automation Modules which should be created in this Automation Account.
  `name` - (Required) The name of the Module.
  `module_link` - (Required) The content link block.
    `uri` - (Required) The URI of the content.
    `hash` - (Optional) The hash block.
      `algorithm` - (Required) The algorithm used to hash the content.
      `value` - (Required) The value of the hash.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_modules = {
  "mymodule" = {
    name = "mymodule"
    module_link = {
      uri = "https://example.com/mymodule.zip"
      hash = {
        algorithm = "sha256"
        value     = "1234567890abcdef"
      }
    }
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name = string
    module_link = object({
      uri = string
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_powershell72_modules"></a> [automation\_powershell72\_modules](#input\_automation\_powershell72\_modules)

Description: A list of Automation Powershell 7.2 Modules which should be created in this Automation Account.
  `name` - (Required) The name of the Module.
  `module_link` - (Required) The content link block.
    `uri` - (Required) The URI of the content.
    `hash` - (Optional) The hash block.
      `algorithm` - (Required) The algorithm used to hash the content.
      `value` - (Required) The value of the hash.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_powershell72_modules = {
  "mymodule" = {
    name = "mymodule"
    module_link = {
      uri = "https://example.com/mymodule.zip"
      hash = {
        algorithm = "sha256"
        value     = "1234567890abcdef"
      }
    }
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name = string
    module_link = object({
      uri = string
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_python3_packages"></a> [automation\_python3\_packages](#input\_automation\_python3\_packages)

Description: A list of Automation Python 3 packages which should be created in this Automation Account.
  `name` - (Required) The name of the Module.
  `content_uri` - (Required) The URI of the content. Changing this forces a new Automation Python3 Package to be created.
  `content_version` - (Optional) The version of the content.  The value should meet the system.version class format like `1.1.1`. Changing this forces a new Automation Python3 Package to be created.
  `hash_algorithm` - (Optional) Specify the hash algorithm used to hash the content of the python3 package. Changing this forces a new Automation Python3 Package to be created.
  `hash_value` - (Optional) Specity the hash value of the content. Changing this forces a new Automation Python3 Package to be created.
  `tags` - (Optional) A mapping of tags to assign to the Module.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_python3_packages = {
  "mypackage" = {
    name            = "mypackage"
    content_uri     = "https://example.com/mypackage.zip"
    content_version = "1.1.1"
    hash_algorithm  = "sha256"
    hash_value      = "1234567890abcdef"
    tags            = {
      environment = "test"
      owner       = "devops"
    }
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name            = string
    content_uri     = string
    content_version = optional(string) # format should be like 1.1.1
    hash_algorithm  = optional(string)
    hash_value      = optional(string)
    tags            = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_runbooks"></a> [automation\_runbooks](#input\_automation\_runbooks)

Description: A list of Automation Runbooks which should be created in this Automation Account.
  `name` - (Required) The name of the Runbook.
  `runbook_type` - (Required) The type of the Runbook. Possible values are `PowerShell`, `PowerShellWorkflow`, `Graph`, `GraphPowerShell`, `GraphPowerShellWorkflow`, `GraphPython2`, `GraphPython3`, `GraphPowerShellCore`, `GraphPowerShellCoreWorkflow`, `GraphPowerShellCorePython2`, `GraphPowerShellCorePython3`, `GraphPowerShellCorePowerShell`, `GraphPowerShellCorePowerShellWorkflow`, `GraphPowerShellCorePowerShellPython2`, `GraphPowerShellCorePowerShellPython3`, `GraphPowerShellCorePowerShellCore`, `GraphPowerShellCorePowerShellCoreWorkflow`, `GraphPowerShellCorePowerShellCorePython2`, `GraphPowerShellCorePowerShellCorePython3`.
  `log_process` - (Required) Whether to log process details. Defaults to `true`.
  `log_verbose` - (Required) Whether to log verbose details. Defaults to `true`.
  `description` - (Optional) A description for this Runbook.
  `content` - (Optional) The content of the Runbook. Required if `publish_content_link` is not specified.
  `tags` - (Optional) A mapping of tags to assign to the Runbook.
  `log_activity_trace_level` - (Optional) The log activity trace level. Defaults to `null`.
  `publish_content_link` - (Optional) The publish content link block.
    `uri` - (Required) The URI of the content.
    `version` - (Optional) The version of the content.
    `hash` - (Optional) The hash block.
      `algorithm` - (Required) The algorithm used to hash the content.
      `value` - (Required) The value of the hash.
  `draft` - (Optional) The draft block.
    `edit_mode_enabled` - (Optional) Whether edit mode is enabled. Defaults to `null`.
    `output_types` - (Optional) A list of output types.
    `content_link` - (Optional) The content link block.
      `uri` - (Required) The URI of the content.
      `version` - (Optional) The version of the content.
      `hash` - (Optional) The hash block.
        `algorithm` - (Required) The algorithm used to hash the content.
        `value` - (Required) The value of the hash.
    `parameters` - (Optional) A list of parameters.
      `default_value` - (Optional) The default value of the parameter.
      `key` - (Required) The key of the parameter.
      `mandatory` - (Optional) Whether the parameter is mandatory. Defaults to `null`.
      `position` - (Optional) The position of the parameter.
      `type` - (Required) The type of the parameter.
  `job_schedule` - (Optional) The job schedule block.
    `parameters` - (Required) A mapping of parameters.
    `run_on` - (Required) The run on value.
    `schedule_name` - (Required) The name of the schedule.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_runbooks = {
  "myrunbook" = {
    name                     = "myrunbook"
    runbook_type             = "PowerShell"
    log_progress             = true
    log_verbose              = true
    description              = "My Runbook"
    content                  = "My Runbook Content"
    tags                     = {
      environment = "test"
      owner       = "devops"
    }
    log_activity_trace_level = 1
    publish_content_link = {
      uri     = "https://example.com/mypublishcontent.zip"
      version = "1.0.0"
      hash    = {
        algorithm = "sha256"
        value     = "1234567890abcdef"
      }
    }
    draft = {
      edit_mode_enabled = true
      output_types      = ["json"]
      content_link = {
        uri     = "https://example.com/mycontent.zip"
        version = "1.0.0"
        hash    = {
          algorithm = "sha256"
          value     = "1234567890abcdef"
        }
      }
      parameters = [
        {
          default_value = "default"
          key           = "mykey"
          mandatory     = true
          position      = 1
          type          = "string"
        }
      ]
    }
    job_schedule = {
      parameters    = {"param1"="value1"}
      run_on        = "Azure"
      schedule_name = "myschedule"
    }
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name                     = string
    runbook_type             = string
    log_progress             = bool
    log_verbose              = bool
    description              = optional(string, "test")
    content                  = optional(string, null)
    tags                     = optional(map(string))
    log_activity_trace_level = optional(number, null)
    publish_content_link = optional(object({
      uri     = string
      version = optional(string)
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    }))
    draft = optional(object({
      edit_mode_enabled = optional(bool)
      output_types      = optional(list(string))
      content_link = optional(object({
        uri     = string
        version = optional(string)
        hash = optional(object({
          algorithm = string
          value     = string
        }))
      }))
      parameters = optional(list(object({
        default_value = optional(string)
        key           = string
        mandatory     = optional(bool)
        position      = optional(number)
        type          = string
      })))
    }))
    job_schedule = optional(object({
      parameters    = optional(map(string))
      run_on        = optional(string)
      schedule_name = string
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_schedules"></a> [automation\_schedules](#input\_automation\_schedules)

Description: A list of Automation Schedules which should be created in this Automation Account.
  `name` - (Required) The name of the Schedule.
  `frequency` - (Required) The frequency of the Schedule. Possible values are `OneTime`, `Hour`, `Day`, `Week` or `Month`.
  `description` - (Optional) A description for this Schedule.
  `interval` - (Optional) The number of `frequencys` between runs. Only valid when frequency is `Day`, `Hour`, `Week`, or `Month` and defaults to `1`.
  `start_time` - (Optional) The start time of the Schedule. Must be at least five minutes in the future. Defaults to seven minutes in the future from the time the resource is created.
  `expiry_time` - (Optional) The expiry time of the Schedule.
  `timezone` - (Optional) The timezone of the Schedule. Defaults to `UTC`.For possible values see: https://docs.microsoft.com/en-us/rest/api/maps/timezone/gettimezoneenumwindows.
  `week_days` - (Optional) List of days of the week that the job should execute on. Only valid when frequency is `Week`. Possible values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday` and `Sunday`.
  `month_days` - (Optional) List of days of the month that the job should execute on. Must be between `1` and `31`. `-1` for last day of the month. Only valid when frequency is `Month`.
  `monthly_occurrence` - (Optional) One monthly\_occurrence blocks as defined below to specifies occurrences of days within a month. Only valid when frequency is `Month`.
    `day` - (Required) The day of the month.
    `occurrence` - (Required) The occurrence of the day in the month.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_schedules = {
  "myschedule" = {
    name        = "myschedule"
    frequency   = "Week"
    description = "My Schedule"
    interval    = 1
    start_time  = "2023-10-01T00:00:00Z"
    expiry_time = "2023-12-31T23:59:59Z"
    timezone    = "UTC"
    week_days   = ["Monday", "Wednesday"]
    month_days  = [1, 15, -1]
    monthly_occurrence = {
      day       = "Monday"
      occurence = 2
    }
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    frequency   = string
    description = optional(string, null)
    interval    = optional(number, 1)
    start_time  = optional(string)
    expiry_time = optional(string)
    timezone    = optional(string, "UTC")
    week_days   = optional(set(string))
    month_days  = optional(set(number))
    monthly_occurrence = optional(object({
      day       = string
      occurence = number
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_source_controls"></a> [automation\_source\_controls](#input\_automation\_source\_controls)

Description: A list of Automation Source Controls which should be created in this Automation Account.
  `name` - (Required) The name of the Source Control.
  `folder_path` - (Required) The folder path in the repository.
  `repository_url` - (Required) The URL of the repository.
  `source_control_type` - (Required) The type of the source control. Possible values are `GitHub`, `VsoGit` and `VsoTfvc`.
  `automatic-sync` - (Optional) Whether to automatically sync the source control. Defaults to `false`.
  `branch` - (Optional) The branch of the repository. Empty value is valid only for `VsoTfvc`.
  `description` - (Optional) A description for this Source Control.
  `publish_runbook_enabled` - (Optional) Whether to publish the runbook. Defaults to `true`.
  `security` - (Required) The security block.
    `token` - (Required) The token to use for the source control.
    `token_type` - (Required) The type of the token. Possible values are `PersonalAccessToken` and `oauth`.
    `refresh_token` - (Optional) The refresh token to use for the source control.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_source_controls = {
  "mysourcecontrol" = {
    name                = "example-source-control"
    description         = "This is an example source control"
    source_control_type = "GitHub"
    folder_path         = "/"
    repository_url      = "https://github.com/ABCD/XYZ.git"
    branch              = "dev"

    security = {
      token_type = "PersonalAccessToken"
      token      = "ghp_xxxxxx"
    }
  }
}
```

Type:

```hcl
map(object({
    name                    = string
    folder_path             = string
    repository_url          = string
    source_control_type     = string # GitHub, VsoGit and VsoTfvc
    automatic_sync          = optional(bool, false)
    branch                  = optional(string) # Empty value is valid only for VsoTfvc.
    description             = optional(string)
    publish_runbook_enabled = optional(bool, true)
    security = object({
      token         = string
      token_type    = string # Personal Access Token or oauth
      refresh_token = optional(string)
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_variable_bools"></a> [automation\_variable\_bools](#input\_automation\_variable\_bools)

Description: A list of Automation Variables of type `Bool` which should be created in this Automation Account.
  `name` - (Required) The name of the Variable.
  `value` - (Optional) The value of the Variable. Defaults to `true`.
  `description` - (Optional) A description for this Variable.
  `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_variable_bools = {
  "mybool" = {
    name        = "mybool"
    value       = true
    description = "My Bool Variable"
    encrypted   = false
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    value       = optional(bool, true)
    description = optional(string)
    encrypted   = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_variable_datetimes"></a> [automation\_variable\_datetimes](#input\_automation\_variable\_datetimes)

Description: A list of Automation Variables of type `DateTime` which should be created in this Automation Account.
  `name` - (Required) The name of the Variable.
  `value` - (Optional) The value of the Variable.
  `description` - (Optional) A description for this Variable.
  `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_variable_datetimes = {
  "mydatetime" = {
    name        = "mydatetime"
    value       = "2023-10-01T00:00:00Z"
    description = "My DateTime Variable"
    encrypted   = false
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    value       = optional(string)
    description = optional(string)
    encrypted   = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_variable_ints"></a> [automation\_variable\_ints](#input\_automation\_variable\_ints)

Description: A list of Automation Variables of type `Int` which should be created in this Automation Account.
  `name` - (Required) The name of the Variable.
  `value` - (Optional) The value of the Variable.
  `description` - (Optional) A description for this Variable.
  `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_variable_ints = {
  "myint" = {
    name        = "myint"
    value       = 123
    description = "My Int Variable"
    encrypted   = false
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    value       = optional(number)
    description = optional(string)
    encrypted   = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_variable_objects"></a> [automation\_variable\_objects](#input\_automation\_variable\_objects)

Description: A list of Automation Variables of type `Object` which should be created in this Automation Account.
  `name` - (Required) The name of the Variable.
  `value` - (Optional) The value of the Variable.
  `description` - (Optional) A description for this Variable.
  `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_variable_objects = {
  "myobject" = {
    name        = "myobject"
    value       = "{\"key\":\"value\"}"
    description = "My Object Variable"
    encrypted   = false
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    value       = optional(string)
    description = optional(string)
    encrypted   = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_variable_strings"></a> [automation\_variable\_strings](#input\_automation\_variable\_strings)

Description: A list of Automation Variables of type `String` which should be created in this Automation Account.
  `name` - (Required) The name of the Variable.
  `value` - (Optional) The value of the Variable.
  `description` - (Optional) A description for this Variable.
  `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_variable_strings = {
  "mystring" = {
    name        = "mystring"
    value       = "My String Variable"
    description = "My String Variable"
    encrypted   = false
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name        = string
    value       = optional(string)
    description = optional(string)
    encrypted   = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_watchers"></a> [automation\_watchers](#input\_automation\_watchers)

Description: A list of Automation Watchers which should be created in this Automation Account.
  `name` - (Required) The name of the Watcher.
  `runbook_key` - (Required) The key of the Runbook to use for this Watcher.
  `hybrid_worker_group_key` - (Required) The key of the Hybrid Worker Group to use for this Watcher. Use `Azure` if you dont want to use hybrid worker
  `execution_frequency_in_seconds` - (Required) The frequency in seconds at which the Watcher should run.
  `etag` - (Optional) A string of etag assigned to this Automation Watcher.
  `script_parameters` - (Optional) Specifies a list of key-vaule parameters. Changing this forces a new Automation watcher to be created.
  `tags` - (Optional) A mapping of tags to assign to the Watcher.
  `description` - (Optional) A description for this Watcher.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_watchers = {
  "mywatcher" = {
    name                           = "mywatcher"
    runbook_key                    = "myrunbook"
    hybrid_worker_group_key        = "mygroup"
    execution_frequency_in_seconds = 60
    etag                           = "etag_value"
    script_parameters              = {"param1"="value1"}
    tags                           = {
      environment = "test"
      owner       = "devops"
    }
    description                    = "My Watcher"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name                           = string
    runbook_key                    = string
    hybrid_worker_group_key        = string
    execution_frequency_in_seconds = number
    etag                           = optional(string)
    script_parameters              = optional(map(string))
    tags                           = optional(map(string))
    description                    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_automation_webhooks"></a> [automation\_webhooks](#input\_automation\_webhooks)

Description: A list of webhook to be created for an Automation runbook in this Automation Account.
  `name` - (Required) Specifies the name of the Webhook. Changing this forces a new resource to be created.
  `expiry_time` - (Required) Timestamp when the webhook expires. Changing this forces a new resource to be created.
  `enabled` - (Optional) Controls if Webhook is enabled. Defaults to `true`.
  `runbook_name` - (Required) Name of the Automation Runbook to execute by Webhook.
  `run_on_worker_group` - (Optional) Name of the hybrid worker group the Webhook job will run on.
  `parameters` - (Optional) Map of input parameters passed to runbook.
  `uri` - (Optional) The URI of the webhook. Changing this forces a new resource to be created.
  `timeouts` - (Optional) The timeouts block.

Example Input:
```terraform
automation_webhooks = {
  "mywebhook" = {
    name                = "mywebhook"
    expiry_time         = "2023-12-31T23:59:59Z"
    enabled             = true
    runbook_name        = "myrunbook"
    run_on_worker_group = "mygroup"
    parameters          = {"param1"="value1"}
    uri                 = "https://example.com/mywebhook"
    timeouts = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  }
}
```

Type:

```hcl
map(object({
    name                = string
    expiry_time         = string
    enabled             = optional(bool, true)
    runbook_name        = string
    run_on_worker_group = optional(string)
    parameters          = optional(map(string))
    uri                 = optional(string, null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description:   A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description:   This variable controls whether or not telemetry is enabled for the module.  
  For more information see <https://aka.ms/avm/telemetryinfo>.  
  If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_encryption"></a> [encryption](#input\_encryption)

Description: - `key_source` -
- `key_vault_key_id` - (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this Automation Account.
- `user_assigned_identity_id` - (Optional) The User Assigned Managed Identity ID to be used for accessing the Customer Managed Key for encryption.

> Note: The `key_source` property is deprecated and will be removed in a future version. Please use `key_vault_key_id` instead.

Type:

```hcl
list(object({
    #key_source                = optional(string) #This is deprecated
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string)
  }))
```

Default: `null`

### <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled)

Description: (Optional) Whether requests using non-AAD authentication are blocked. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description:   Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description:   A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
    - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
    - `principal_id` - The ID of the principal to assign the role to.
    - `description` - (Optional) The description of the role assignment.
    - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
    - `condition` - (Optional) The condition which will be used to scope the role assignment.
    - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
    - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
    - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  - `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
    - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `subresource_name` - The name of the sub resource for the private endpoint.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string # NOTE: `subresource_name` can be excluded if the resource does not support multiple sub resource types (e.g. storage account supports blob, queue, etc)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: (Optional) Whether public network access is allowed for the automation account. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

  Example Input:
  ```terraform
  role_assignments = {
    "myroleassignment" = {
      role_definition_id_or_name             = "Reader"
      principal_id                           = "12345678-1234-1234-1234-123456789012"
      description                            = "My Role Assignment"
      skip_service_principal_aad_check       = false
      condition                              = null
      condition_version                      = null
      delegated_managed_identity_resource_id = null
      principal_type                         = null
    }
  }
```

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: - `create` - (Defaults to 30 minutes) Used when creating the Automation Account.
- `delete` - (Defaults to 30 minutes) Used when deleting the Automation Account.
- `read` - (Defaults to 5 minutes) Used when retrieving the Automation Account.
- `update` - (Defaults to 30 minutes) Used when updating the Automation Account.

Type:

```hcl
object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_automation_account_id"></a> [automation\_account\_id](#output\_automation\_account\_id)

Description: ID of the automation account

### <a name="output_automation_account_name"></a> [automation\_account\_name](#output\_automation\_account\_name)

Description: Name of the automation account

### <a name="output_hybrid_service_url"></a> [hybrid\_service\_url](#output\_hybrid\_service\_url)

Description: Hybrid worker group URL for the automation account

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description:   A map of the private endpoints created.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: ID of the automation account

### <a name="output_system_assigned_mi_principal_id"></a> [system\_assigned\_mi\_principal\_id](#output\_system\_assigned\_mi\_principal\_id)

Description: The system assigned managed identity of the automation account

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->