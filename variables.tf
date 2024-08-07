variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the Automation Account."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  nullable    = false
}

variable "sku" {
  type        = string
  description = "The SKU of the Automation Account. Possible values are Basic and Free"
  nullable    = false
}

variable "encryption" {
  type = list(object({
    #key_source                = optional(string) #This is deprecated
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string)
  }))
  default     = null
  description = <<-EOT
  - `key_source` - 
  - `key_vault_key_id` - (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this Automation Account.
  - `user_assigned_identity_id` - (Optional) The User Assigned Managed Identity ID to be used for accessing the Customer Managed Key for encryption.
EOT
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-EOT
  - `identity_ids` - (Optional) The ID of the User Assigned Identity which should be assigned to this Automation Account.
  - `type` - (Required) The type of identity used for this Automation Account. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
EOT
}

variable "local_authentication_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether requests using non-AAD authentication are blocked. Defaults to `true`."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether public network access is allowed for the automation account. Defaults to `true`."
}


variable "timeouts" {
  type = object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
  default     = null
  description = <<-EOT
  - `create` - (Defaults to 30 minutes) Used when creating the Automation Account.
  - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Account.
  - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Account.
  - `update` - (Defaults to 30 minutes) Used when updating the Automation Account.
EOT
}

variable "automation_certificates" {
  type = map(object({
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
  default     = {}
  description = <<-EOT
  A list of Automation Certificates which should be created in this Automation Account.
    `name` - (Required) The name of the Certificate.
    `base64` - (Required) The base64 encoded value of the Certificate.
    `description` - (Optional) A description for this Certificate.
    `exportable` - (Optional) Whether the Certificate is exportable. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
EOT
  nullable    = false
}

variable "automation_connections" {
  type = map(object({
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
  default     = {}
  description = <<-EOT
  A list of Automation Connections which should be created in this Automation Account.
    `name` - (Required) The name of the Connection.
    `type` - (Required) The type of the Connection.
    `values` - (Required) A mapping of key value pairs passed to the connection. Different `type` needs different parameters in the `values`. Builtin types have required field values as below:
      `Azure`: parameters `AutomationCertificateName` and `SubscriptionID`.
      `AzureServicePrincipal`: parameters `TenantID`, `ApplicationID`, and `CertificateThumbprint`.
      `AzureClassicCertificate`: parameters `SubscriptionID`, `SubscriptionName`, and `CertificateAsserName`.
    `description` - (Optional) A description for this Connection.
    `timeouts` - (Optional) The timeouts block.
EOT
  nullable    = false
}

variable "automation_connection_certificates" {
  type = map(object({
    connection_key              = string
    subscription_id             = string
    automation_certificate_name = string
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Connection Certificates which should be created in this Automation Account.
    `connection_key` - (Required) The key of the Connection to use for this Connection Certificate.
    `subscription_id` - (Required) The Subscription ID to use for this Connection Certificate.
    `automation_certificate_name` - (Required) The name of the Automation Certificate to use for this Connection Certificate.
  EOT
  nullable    = false
}

variable "automation_connection_service_principals" {
  type = map(object({
    connection_key         = string
    tenant_id              = string
    application_id         = string
    certificate_thumbprint = string
    subscription_id        = string
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Connection Service Principals which should be created in this Automation Account.
    `connection_key` - (Required) The key of the Connection to use for this Connection Service Principal.
    `tenant_id` - (Required) The Tenant ID to use for this Connection Service Principal.
    `application_id` - (Required) The Application ID to use for this Connection Service Principal.
    `certificate_thumbprint` - (Required) The Certificate Thumbprint to use for this Connection Service Principal.
    `subscription_id` - (Required) The Subscription ID to use for this Connection Service Principal.
  EOT
  nullable    = false
}

variable "automation_connection_classic_certificates" {
  type = map(object({
    connection_key         = string
    subscription_id        = string
    subscription_name      = string
    certificate_asset_name = string
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Connection Classic Certificates which should be created in this Automation Account.
    `connection_key` - (Required) The key of the Connection to use for this Connection Classic Certificate.
    `subscription_id` - (Required) The Subscription ID to use for this Connection Classic Certificate.
    `subscription_name` - (Required) The Subscription Name to use for this Connection Classic Certificate.
    `certificate_asset_name` - (Required) The name of the certificate asset to use for this Connection Classic Certificate.
  EOT
  nullable    = false
}

variable "automation_credentials" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Credentials which should be created in this Automation Account.
    `name` - (Required) The name of the Credential.
    `username` - (Required) The username associated with this Automation Credential.
    `password` - (Required) The password associated with this Automation Credential.
    `description` - (Optional) A description associated with this Automation Credential.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_schedules" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Schedules which should be created in this Automation Account.
    `name` - (Required) The name of the Schedule.
    `frequency` - (Required) The frequency of the Schedule. Possible values are `OneTime`, `Hour`, `Day`, `Week` or `Month`.
    `description` - (Optional) A description for this Schedule.
    `interval` - (Optional) The number of `frequencys` between runs. Only valid when frequency is `Day`, `Hour`, `Week`, or `Month` and defaults to `1`.
    `start_time` - (Optional) The start time of the Schedule. Must be at least five minutes in the future. Defaults to seven minutes in the future from the time the resource is created.
    `expiry_time` - (Optional) The expiry time of the Schedule.
    `timezone` - (Optional) The timezone of the Schedule. Defaults to `UTC`.For possible values see: https://docs.microsoft.com/en-us/rest/api/maps/timezone/gettimezoneenumwindows.
    `week_days` - (Optional) List of days of the week that the job should execute on. Only valid when frequency is `Week`. Possible values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday` and `Sunday`.
    `month_days` - (Optional) List of days of the month that the job should execute on. Must be between `1` and `31`. `-1` for last day of the month. Only valid when frequency is `Month`.
    `monthly_occurrence` - (Optional) One monthly_occurrence blocks as defined below to specifies occurrences of days within a month. Only valid when frequency is `Month`.
      `day` - (Required) The day of the month.
      `occurrence` - (Required) The occurrence of the day in the month.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_modules" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Modules which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `module_link` - (Required) The content link block.
      `uri` - (Required) The URI of the content.
      `hash` - (Optional) The hash block.
        `algorithm` - (Required) The algorithm used to hash the content.
        `value` - (Required) The value of the hash.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_powershell72_modules" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Powershell 7.2 Modules which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `module_link` - (Required) The content link block.
      `uri` - (Required) The URI of the content.
      `hash` - (Optional) The hash block.
        `algorithm` - (Required) The algorithm used to hash the content.
        `value` - (Required) The value of the hash.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_python3_packages" {
  type = map(object({
    name            = string
    content_uri     = string
    content_version = optional(string) // format should be like 1.1.1
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Python 3 packages which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `content_uri` - (Required) The URI of the content. Changing this forces a new Automation Python3 Package to be created.
    `content_version` - (Optional) The version of the content.  The value should meet the system.version class format like `1.1.1`. Changing this forces a new Automation Python3 Package to be created.
    `hash_algorithm` - (Optional) Specify the hash algorithm used to hash the content of the python3 package. Changing this forces a new Automation Python3 Package to be created.
    `hash_value` - (Optional) Specity the hash value of the content. Changing this forces a new Automation Python3 Package to be created.
    `tags` - (Optional) A mapping of tags to assign to the Module.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_variable_bools" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Variables of type `Bool` which should be created in this Automation Account.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable. Defaults to `true`.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_variable_datetimes" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Variables of type `DateTime` which should be created in this Automation Account.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_variable_ints" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Variables of type `Int` which should be created in this Automation Account.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_variable_objects" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Variables of type `Object` which should be created in this Automation Account.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_variable_strings" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Variables of type `String` which should be created in this Automation Account.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
  EOT
}

variable "automation_runbooks" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Runbooks which should be created in this Automation Account.
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
EOT
}

variable "automation_webhooks" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of webhook to be created for an Automation runbook in this Automation Account.
    `name` - (Required) Specifies the name of the Webhook. Changing this forces a new resource to be created.
    `expiry_time` - (Required) Timestamp when the webhook expires. Changing this forces a new resource to be created.
    `enabled` - (Optional) Controls if Webhook is enabled. Defaults to `true`.
    `runbook_name` - (Required) Name of the Automation Runbook to execute by Webhook.
    `run_on_worker_group` - (Optional) Name of the hybrid worker group the Webhook job will run on.
    `parameters` - (Optional) Map of input parameters passed to runbook.
    `uri` - (Optional) The URI of the webhook. Changing this forces a new resource to be created.
    `timeouts` - (Optional) The timeouts block.
EOT
}

variable "automation_hybrid_runbook_worker_groups" {
  type = map(object({
    name            = string
    credential_name = optional(string, null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Hybrid Runbook Worker Groups which should be created in this Automation Account.
    `name` - (Required) The name of the Hybrid Runbook Worker Group.
    `credential_name` - (Optional) The name of resource type azurerm_automation_credential to use for hybrid worker.
    `timeouts` - (Optional) The timeouts block.
EOT
}

variable "automation_hybrid_runbook_workers" {
  type = map(object({
    hybrid_worker_group_key = string
    vm_resource_id          = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Hybrid Runbook Workers which should be created in this Automation Account.
    `Hybrid_worker_group_key` - (Required) The key of the Hybrid Runbook Worker Group to which this Hybrid Runbook Worker belongs.
    `vm_resource_id` - (Required) The Resource ID of the Virtual Machine to use as a Hybrid Runbook Worker.
    `timeouts` - (Optional) The timeouts block.
EOT
}

variable "automation_watchers" {
  type = map(object({
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
  default     = {}
  nullable    = false
  description = <<-EOT
  A list of Automation Watchers which should be created in this Automation Account.
    `name` - (Required) The name of the Watcher.
    `runbook_key` - (Required) The key of the Runbook to use for this Watcher.
    `hybrid_worker_group_key` - (Required) The key of the Hybrid Worker Group to use for this Watcher. Use `Azure` if you dont want to use hybrid worker
    `execution_frequency_in_seconds` - (Required) The frequency in seconds at which the Watcher should run.
    `etag` - (Optional) A string of etag assigned to this Automation Watcher.
    `script_parameters` - (Optional) Specifies a list of key-vaule parameters. Changing this forces a new Automation watcher to be created.
    `tags` - (Optional) A mapping of tags to assign to the Watcher.
    `description` - (Optional) A description for this Watcher.
    `timeouts` - (Optional) The timeouts block.
EOT
}

variable "automation_source_controls" {
  type = map(object({
    name                    = string
    folder_path             = string
    repository_url          = string
    source_control_type     = string // GitHub, VsoGit and VsoTfvc
    automatic_sync          = optional(bool, false)
    branch                  = optional(string) // Empty value is valid only for VsoTfvc.
    description             = optional(string)
    publish_runbook_enabled = optional(bool, true)
    security = object({
      token         = string
      token_type    = string // Personal Access Token or oauth
      refresh_token = optional(string)
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = <<-EOT
A list of Automation Source Controls which should be created in this Automation Account.
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
EOT
}
