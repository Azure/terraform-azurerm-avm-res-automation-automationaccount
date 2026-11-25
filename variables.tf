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

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the existing resource group into which the Automation Account will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid Azure resource group resource ID."
  }
}

variable "sku" {
  type = object({
    capacity = optional(number)
    family   = optional(string)
    name     = string
  })
  description = <<-EOT
  The SKU of the Automation Account.
    `name` - (Required) The name of the SKU. Possible values are Basic and Free.
    `capacity` - (Optional) The capacity of the SKU.
    `family` - (Optional) The family of the SKU.
  EOT
  nullable    = false

  validation {
    condition     = contains(["Basic", "Free"], var.sku.name)
    error_message = "The SKU name must be either 'Basic' or 'Free'."
  }
}

variable "automation_certificates" {
  type = map(object({
    name           = string
    base64         = string
    description    = optional(string)
    exportable     = optional(bool, false)
    thumbprint     = optional(string)
    base64_version = optional(number, 1)
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
    `base64_version` - (Optional) A positive integer, default 1. Increment when replacing `base64`; the certificate payload is write-only and is not persisted in Terraform state.
    `timeouts` - (Optional) Per-certificate operation timeouts, overriding module-level timeouts.
    `description` - (Optional) A description for this Certificate.
    `exportable` - (Optional) Whether the Certificate is exportable. Defaults to `false`.
    `thumbprint` - (Optional) The thumbprint of the Certificate.

  Example Input:

  ```terraform
  automation_certificates = {
    "mycert" = {
      name        = "mycert"
      base64      = "base64encodedvalue"
      description = "My Certificate"
      exportable  = true
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true

  validation {
    condition     = alltrue([for certificate in values(var.automation_certificates) : certificate.base64_version >= 1 && floor(certificate.base64_version) == certificate.base64_version])
    error_message = "Every certificate base64_version must be a positive integer."
  }
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
  A list of Automation Connections which should be created in this Automation Account. Each entry creates one connection. At most one specialized certificate, service principal, or classic certificate entry may reference its key. Specialized fields override matching entries in `values`, and the specialized type must match `type`.
    `name` - (Required) The name of the Connection.
    `type` - (Required) The type of the Connection. Can be either builtin type such as `Azure`, `AzureClassicCertificate`, and `AzureServicePrincipal`, or a user defined types. Changing this forces a new resource to be created.
    `values` - (Required) A mapping of key value pairs passed to the connection. Different `type` needs different parameters in the `values`. Builtin types have required field values as below:
      `Azure`: parameters `AutomationCertificateName` and `SubscriptionID`.
      `AzureServicePrincipal`: parameters `TenantId`, `ApplicationId`, `CertificateThumbprint`, and `SubscriptionId`.
      `AzureClassicCertificate`: parameters `SubscriptionId`, `SubscriptionName`, and `CertificateAssetName`.
    `description` - (Optional) A description for this Connection.
    `timeouts` - (Optional) Per-connection operation timeouts, overriding module-level timeouts.

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
    }
  }
  ```
  EOT
  nullable    = false

  validation {
    condition = alltrue([
      for key, overrides in local.automation_connection_overrides :
      contains(keys(var.automation_connections), key) ? (
        length(overrides) == 1 && alltrue([
          for override in overrides : override.type == var.automation_connections[key].type
        ])
      ) : false
    ])
    error_message = "Each specialized connection must reference an existing automation_connections key with a matching type, and at most one specialized entry may reference each connection."
  }
}

variable "automation_credentials" {
  type = map(object({
    name             = string
    username         = string
    password         = string
    description      = optional(string)
    password_version = optional(number, 1)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Credentials which should be created in this Automation Account.
    `name` - (Required) The name of the Credential.
    `username` - (Required) The username associated with this Automation Credential.
    `password` - (Required) The password associated with this Automation Credential.
    `password_version` - (Optional) A positive integer, default 1. Increment when changing `password`; the password is write-only and is not persisted in Terraform state.
    `timeouts` - (Optional) Per-credential operation timeouts, overriding module-level timeouts.
    `description` - (Optional) A description associated with this Automation Credential.

  Example Input:
  ```terraform
  automation_credentials = {
    "mycredential" = {
      name        = "mycredential"
      username    = "myusername"
      password    = "mypassword"
      description = "My Credential"
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true

  validation {
    condition     = alltrue([for credential in values(var.automation_credentials) : credential.password_version >= 1 && floor(credential.password_version) == credential.password_version])
    error_message = "Every credential password_version must be a positive integer."
  }
}

variable "automation_hybrid_runbook_worker_groups" {
  type = map(object({
    credential_name = string
    name            = string
  }))
  default     = {}
  description = <<-EOT
  A list of Hybrid Runbook Worker Groups which should be created in this Automation Account.
    `credential_name` - (Required) The name of the automation credential to use for hybrid worker.
    `name` - (Required) The name of the Hybrid Runbook Worker Group.

  Example Input:
  ```terraform
  automation_hybrid_runbook_worker_groups = {
    "mygroup" = {
      name            = "mygroup"
      credential_name = "mycredential"
    }
  }
  ```
  EOT
  nullable    = false
}

variable "automation_hybrid_runbook_workers" {
  type = map(object({
    hybrid_worker_group_key = string
    vm_resource_id          = string
  }))
  default     = {}
  description = <<-EOT
  A list of Hybrid Runbook Workers which should be created in this Automation Account.
    `hybrid_worker_group_key` - (Required) The key of the Hybrid Runbook Worker Group to which this Hybrid Runbook Worker belongs.
    `vm_resource_id` - (Required) The Resource ID of the Virtual Machine to use as a Hybrid Runbook Worker.

  Example Input:
  ```terraform
  automation_hybrid_runbook_workers = {
    "myworker" = {
      hybrid_worker_group_key = "mygroup"
      vm_resource_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/mygroup/providers/Microsoft.Compute/virtualMachines/myvm"
    }
  }
  ```
  EOT
  nullable    = false
}

variable "automation_job_schedules" {
  type = map(object({
    job_schedule_id = optional(string)
    runbook_key     = string
    schedule_key    = string
    parameters      = optional(map(string)) # must be in lowercase
    run_on          = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
  A map of Automation Job Schedules managed with AzAPI. You can also use the inline `job_schedule` property under `automation_runbooks`, but each runbook/schedule pair must be declared only once across both inputs.
    `runbook_key` - (Required) The key of the Runbook defined in `automation_runbooks`.
    `schedule_key` - (Required) The key of the Schedule defined in `automation_schedules`.
    `parameters` - (Optional) A map of parameters to pass to the Runbook.
    `run_on` - (Optional) The name of the Hybrid Worker Group the job will run on.
    `job_schedule_id` - (Optional) Existing ARM job schedule GUID to retain and import during migration. Omit for a deterministic GUID on new associations. Standalone and inline legacy GUIDs must be supplied explicitly; they cannot be recovered from runbook state automatically.
    `timeouts` - (Optional) Per-job operation timeouts overriding module defaults.

  Example Input:
  ```terraform
  automation_job_schedules = {
    "myjobschedule" = {
      runbook_key  = "auto_runbook_key1"
      schedule_key = "auto_schedule_key1"
      parameters    = {
        param1 = "value1"
        param2 = "value2"
      }
      run_on = "Azure"
    }
  }
  ```
  EOT
  nullable    = false

  validation {
    condition = alltrue([
      for job in concat(values(var.automation_job_schedules), values(local.automation_runbook_job_schedules)) :
      job.job_schedule_id == null ? true : can(regex("(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", job.job_schedule_id))
    ])
    error_message = "Each job_schedule_id must be an existing job schedule GUID, not a full resource ID."
  }
  validation {
    condition = length(distinct([
      for job in concat(values(var.automation_job_schedules), values(local.automation_runbook_job_schedules)) : lower(job.job_schedule_id)
      if job.job_schedule_id != null
      ])) == length([
      for job in concat(values(var.automation_job_schedules), values(local.automation_runbook_job_schedules)) : job.job_schedule_id
      if job.job_schedule_id != null
    ])
    error_message = "Existing job schedule GUIDs must be unique across standalone and inline associations."
  }
  validation {
    condition = alltrue([
      for job in values(var.automation_job_schedules) :
      contains(keys(var.automation_runbooks), job.runbook_key) && contains(keys(var.automation_schedules), job.schedule_key)
    ])
    error_message = "Each job schedule must reference an existing automation_runbooks key and automation_schedules key."
  }
  validation {
    condition     = length(setintersection(toset(keys(var.automation_job_schedules)), toset(keys(local.automation_runbook_job_schedules)))) == 0
    error_message = "Standalone job schedule keys must not collide with generated inline keys (JSON arrays containing runbook, runbook key, and schedule key)."
  }
  validation {
    condition = length(distinct(concat(
      [for job in values(var.automation_job_schedules) : jsonencode([job.runbook_key, job.schedule_key])],
      [for job in values(local.automation_runbook_job_schedules) : jsonencode([job.runbook_key, job.schedule_key])],
    ))) == length(var.automation_job_schedules) + length(local.automation_runbook_job_schedules)
    error_message = "Each runbook/schedule pair must be declared only once across standalone and inline job schedules."
  }
}

variable "automation_modules" {
  type = map(object({
    name            = string
    content_uri     = string
    content_version = optional(string) # format should be like 1.1.1
    hash_algorithm  = optional(string)
    hash_value      = optional(string)
    tags            = optional(map(string))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Modules which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `content_uri` - (Required) The URI of the content.
    `content_version` - (Optional) The version of the content.  The value should meet the system.version class format like `1.1.1`.
    `hash_algorithm` - (Optional) The algorithm used to hash the content.
    `hash_value` - (Optional) The value of the hash.

  Example Input:
  ```terraform
  automation_modules = {
    "mymodule" = {
      name = "mymodule"
      content_uri = "https://example.com/mymodule.zip"
      hash_algorithm = "sha256"
      hash_value     = "1234567890abcdef"
    }
  }
  ```
  EOT
  nullable    = false
}

variable "automation_powershell72_modules" {
  type = map(object({
    name            = string
    content_uri     = string
    content_version = optional(string) # format should be like 1.1.1
    hash_algorithm  = optional(string)
    hash_value      = optional(string)
    tags            = optional(map(string))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Powershell 7.2 Modules which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `content_uri` - (Required) The URI of the content.
    `content_version` - (Optional) The version of the content.  The value should meet the system.version class format like `1.1.1`.
    `hash_algorithm` - (Optional) The algorithm used to hash the content.
    `hash_value` - (Optional) The value of the hash.
    `tags` - (Optional) The tags to associate with the module.

  Example Input:
  ```terraform
  automation_powershell72_modules = {
    "mymodule" = {
      name = "mymodule"
      content_uri = "https://example.com/mymodule.zip"
      hash_algorithm = "sha256"
      hash_value     = "1234567890abcdef"
      content_version = "1.0.0"
    }
  }
  ```
  EOT
  nullable    = false
}

variable "automation_python3_packages" {
  type = map(object({
    name            = string
    content_uri     = string
    content_version = optional(string) # format should be like 1.1.1
    hash_algorithm  = optional(string)
    hash_value      = optional(string)
    tags            = optional(map(string))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Python 3 packages which should be created in this Automation Account.
    `name` - (Required) The name of the Module.
    `content_uri` - (Required) The URI of the content. Changing this forces a new Automation Python3 Package to be created.
    `content_version` - (Optional) The version of the content.  The value should meet the system.version class format like `1.1.1`. Changing this forces a new Automation Python3 Package to be created.
    `hash_algorithm` - (Optional) Specify the hash algorithm used to hash the content of the python3 package. Changing this forces a new Automation Python3 Package to be created.
    `hash_value` - (Optional) Specify the hash value of the content. Changing this forces a new Automation Python3 Package to be created.
    `tags` - (Optional) A mapping of tags to assign to the Module.

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
    }
  }
  ```
  EOT
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.automation_python3_packages :
      v.content_version == null || can(regex("^\\d+\\.\\d+\\.\\d+$", v.content_version))
    ])
    error_message = "If specified, content_version must be in the format 'X.Y.Z', e.g., '1.1.1'."
  }
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
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
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
    job_schedule = optional(list(object({
      job_schedule_id = optional(string)
      parameters      = optional(map(string))
      run_on          = optional(string)
      schedule_key    = string # Must match a key in `automation_schedules`.
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Runbooks which should be created in this Automation Account.
    `name` - (Required) The name of the Runbook.
    `runbook_type` - (Required) The type of the Runbook. Possible values are `PowerShell`, `PowerShellWorkflow`, `Graph`, `GraphPowerShell`, `GraphPowerShellWorkflow`, `PowerShell72`, `Python3`, `Python2` or `Script`.
    `log_progress` - (Required) Whether to log progress details. Defaults to `true`.
    `log_verbose` - (Required) Whether to log verbose details. Defaults to `true`.
    `description` - (Optional) A description for this Runbook.
    `content` - (Unsupported) Inline content requires the raw text/plain ARM upload API, which AzAPI cannot send (Azure/terraform-provider-azapi#507). Non-null values are rejected rather than silently ignored. Use `publish_content_link` for published content or `draft.content_link` for a draft.
    `tags` - (Optional) A mapping of tags to assign to the Runbook.
    `log_activity_trace_level` - (Optional) The log activity trace level. Specifies the activity-level tracing options of the runbook, available only for Graphical runbooks. Possible values are `0` for None, `9` for Basic, and `15` for Detailed. Must turn on Verbose logging in order to see the tracing.
    `timeouts` - (Optional) Per-runbook operation timeouts overriding module defaults, also inherited by inline job schedules unless they specify their own.
    `publish_content_link` - (Optional) The publish content link block.
      `uri` - (Required) The URI of the content.
      `version` - (Optional) The version of the content.
      `hash` - (Optional) The hash block.
        `algorithm` - (Required) The algorithm used to hash the content.
        `value` - (Required) The value of the hash.
    `draft` - (Optional) The draft block.
      `edit_mode_enabled` - (Optional) Whether edit mode is enabled. Defaults to `null` (draft only). With `draft.content_link`, explicitly set `false` to publish the draft after upload. Linked published content is handled by ARM through `publish_content_link`; do not combine that path with a draft. Publishing replaces only the apply-time action record, never the runbook. Removing a draft/publication action does not unpublish existing content.
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
    `job_schedule` - (Optional) A list of associations managed as separate AzAPI job schedules. Each runbook/schedule pair must be declared only once across inline entries and `automation_job_schedules`. Reordering this list does not change resource keys.
      `parameters` - (Optional) A map of parameters to pass to the Runbook.
      `run_on` - (Optional) The name of the Hybrid Worker Group the job will run on.
      `schedule_key` - (Required) The key of the Schedule defined in `automation_schedules`. This must match a key in `automation_schedules`.
      `job_schedule_id` - (Optional) Existing ARM job schedule GUID to retain and import during migration.
      `timeouts` - (Optional) Per-job operation timeouts, overriding runbook and module defaults.

  Example Input:
  ```terraform
  automation_runbooks = {
    "myrunbook" = {
      name                     = "myrunbook"
      runbook_type             = "PowerShell"
      log_progress             = true
      log_verbose              = true
      description              = "My Runbook"
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
      job_schedule = [
        {
          parameters    = {
            param1 = "value1"
            param2 = "value2"
          }
          run_on        = "Azure"
          schedule_key = "my_schedule_key1"
        }
      ]
    }
  }
  ```
  EOT
  nullable    = false

  validation {
    condition     = alltrue([for runbook in values(var.automation_runbooks) : runbook.content == null])
    error_message = "Inline runbook content is not supported by AzAPI's raw request body capabilities (Azure/terraform-provider-azapi#507). Use publish_content_link or draft.content_link; content must not be silently discarded."
  }
  validation {
    condition     = alltrue([for runbook in values(var.automation_runbooks) : runbook.publish_content_link == null || runbook.draft == null])
    error_message = "Use either publish_content_link or draft, not both, to avoid ambiguous publication ownership."
  }
  validation {
    condition = alltrue([
      for runbook in values(var.automation_runbooks) : runbook.draft == null ? true : (
        runbook.draft.parameters == null ? true :
        length(distinct([for parameter in runbook.draft.parameters : parameter.key])) == length(runbook.draft.parameters)
      )
    ])
    error_message = "Draft parameter keys must be unique."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_runbooks :
      contains(
        [
          "PowerShell", "PowerShellWorkflow", "Graph", "GraphPowerShell", "GraphPowerShellWorkflow",
          "PowerShell72", "Python3", "Python2", "Script"
        ],
        v.runbook_type
      )
    ])
    error_message = "The runbook type must be one of the supported types. Possible values are `PowerShell`, `PowerShellWorkflow`, `Graph`, `GraphPowerShell`, `GraphPowerShellWorkflow`, `PowerShell72`, `Python3`, `Python2` or `Script`."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_runbooks :
      v.log_activity_trace_level == null || contains([0, 9, 15], v.log_activity_trace_level)
    ])
    error_message = "log_activity_trace_level must be one of 0 (None), 9 (Basic), or 15 (Detailed) if specified."
  }
  validation {
    condition = alltrue([
      for runbook in values(var.automation_runbooks) : runbook.job_schedule == null ? true : (
        length(distinct([for job in runbook.job_schedule : job.schedule_key])) == length(runbook.job_schedule) &&
        alltrue([for job in runbook.job_schedule : contains(keys(var.automation_schedules), job.schedule_key)])
      )
    ])
    error_message = "Inline job schedules must reference existing automation_schedules keys without repeating a schedule within a runbook."
  }
}

variable "automation_schedules" {
  type = map(object({
    name        = string
    frequency   = string
    description = optional(string, null)
    interval    = optional(number, 1)
    start_time  = optional(string)
    expiry_time = optional(string)
    timezone    = optional(string, "Etc/UTC")
    week_days   = optional(set(string))
    month_days  = optional(set(number))
    monthly_occurrence = optional(object({
      day        = string
      occurrence = number
    }), null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Schedules which should be created in this Automation Account.
    `name` - (Required) The name of the Schedule.
    `frequency` - (Required) The frequency of the Schedule. Possible values are `OneTime`, `Hour`, `Day`, `Week` or `Month`.
    `description` - (Optional) A description for this Schedule.
    `interval` - (Optional) The number of `frequency's` between runs. Only valid when frequency is `Day`, `Hour`, `Week`, or `Month` and defaults to `1`.
    `start_time` - (Optional) The start time of the Schedule. Must be at least five minutes in the future. Defaults to seven minutes in the future from the time the resource is created.
    `expiry_time` - (Optional) The expiry time of the Schedule.
    `timeouts` - (Optional) Per-schedule operation timeouts overriding module defaults.
    `timezone` - (Optional) The timezone of the Schedule. Defaults to `Etc/UTC`.For possible values see: https://docs.microsoft.com/en-us/rest/api/maps/timezone/gettimezoneenumwindows.
    `week_days` - (Optional) List of days of the week that the job should execute on. Only valid when frequency is `Week`. Possible values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday` and `Sunday`.
    `month_days` - (Optional) List of days of the month that the job should execute on. Must be between `1` and `31`. `-1` for last day of the month. Only valid when frequency is `Month`.
    `monthly_occurrence` - (Optional) One monthly_occurrence blocks as defined below to specifies occurrences of days within a month. Only valid when frequency is `Month`.
      `day` - (Required) The day of the month. Must be one of `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`
      `occurrence` - (Required) The occurrence of the day in the month. Must be between `1` and `5`. `-1` for last week within the month.

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
    }
  }
  ```
  EOT
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.automation_schedules :
      contains(["OneTime", "Hour", "Day", "Week", "Month"], v.frequency)
    ])
    error_message = "The frequency must be one of the supported values: OneTime, Hour, Day, Week, or Month."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_schedules :
      v.frequency == "OneTime" ? contains([null, 1], v.interval) : (v.interval == null ? false : v.interval >= 1 && floor(v.interval) == v.interval)
    ])
    error_message = "Recurring interval must be a positive integer. OneTime accepts only the omitted default (1) or null and sends no interval to ARM."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_schedules :
      v.week_days == null ? true : (
        v.frequency == "Week" && alltrue([
          for day in v.week_days :
          contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], day)
        ])
      )
    ])
    error_message = "If specified, week_days must be a list of valid days of the week and only valid when frequency is Week. Possible values are Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, and Sunday."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_schedules :
      v.month_days == null ? true : (
        v.frequency == "Month" && alltrue([
          for day in v.month_days :
          (day >= 1 && day <= 31 && floor(day) == day) || day == -1
        ])
      )
    ])
    error_message = "If specified, month_days must be a list of valid days of the month (1-31) or -1 for the last day of the month and only valid when frequency is Month."
  }
  validation {
    condition = alltrue([
      for _, v in var.automation_schedules :
      v.monthly_occurrence == null ? true : (
        v.frequency == "Month" && (
          contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], v.monthly_occurrence.day) &&
          (v.monthly_occurrence.occurrence >= 1 && v.monthly_occurrence.occurrence <= 5 && floor(v.monthly_occurrence.occurrence) == v.monthly_occurrence.occurrence || v.monthly_occurrence.occurrence == -1)
        )
      )
    ])
    error_message = "If specified, monthly_occurrence must have a valid day (Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) and occurrence (1-5 or -1 for last week) and only valid when frequency is Month."
  }
  validation {
    condition = alltrue([
      for schedule in values(var.automation_schedules) :
      (schedule.start_time == null ? true : can(timeadd(schedule.start_time, "0s"))) &&
      (schedule.expiry_time == null ? true : can(timeadd(schedule.expiry_time, "0s")))
    ])
    error_message = "start_time and expiry_time must be RFC3339 timestamps when supplied."
  }
  validation {
    condition = alltrue([
      for schedule in values(var.automation_schedules) :
      schedule.start_time == null || schedule.expiry_time == null ? true : try(timecmp(schedule.expiry_time, schedule.start_time) > 0, false)
    ])
    error_message = "expiry_time must be later than start_time when both are supplied."
  }
}

variable "automation_source_controls" {
  type = map(object({
    name                    = string
    folder_path             = string
    repository_url          = string
    source_control_type     = string # GitHub, VsoGit and VsoTfvc
    automatic_sync          = optional(bool, false)
    branch                  = string
    description             = optional(string)
    publish_runbook_enabled = optional(bool, true)
    security_token_version  = optional(number, 1)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
    security = object({
      token         = string
      token_type    = string # Personal Access Token or oauth
      refresh_token = optional(string)
    })
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Source Controls which should be created in this Automation Account.
    `name` - (Required) The name of the Source Control.
    `folder_path` - (Required) The folder path in the repository.
    `repository_url` - (Required) The URL of the repository.
    `source_control_type` - (Required) The type of the source control. Possible values are `GitHub`, `VsoGit` and `VsoTfvc`.
    `automatic-sync` - (Optional) Whether to automatically sync the source control. Defaults to `false`.
    `branch` - (Required) The branch of the repository. Empty value is valid only for `VsoTfvc`.
    `description` - (Optional) A description for this Source Control.
    `publish_runbook_enabled` - (Optional) Whether to publish the runbook. Defaults to `true`.
    `security_token_version` - (Optional) A positive integer, default 1. Increment when rotating either token; tokens are write-only and are not persisted in Terraform state.
    `timeouts` - (Optional) Per-source-control operation timeouts, overriding module-level timeouts.
    `security` - (Required) The security block.
      `token` - (Required) The token to use for the source control.
      `token_type` - (Required) The type of the token. Possible values are `PersonalAccessToken` and `Oauth`, matched case-insensitively.
      `refresh_token` - (Optional) The refresh token to use for the source control.

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
  EOT
  nullable    = false
  sensitive   = true

  validation {
    condition = alltrue([
      for _, v in var.automation_source_controls :
      contains(["GitHub", "VsoGit", "VsoTfvc"], v.source_control_type)
    ])
    error_message = "The source_control_type must be one of the supported values: GitHub, VsoGit, or VsoTfvc."
  }
  validation {
    condition     = alltrue([for control in values(var.automation_source_controls) : contains(["personalaccesstoken", "oauth"], lower(control.security.token_type))])
    error_message = "Every security.token_type must be PersonalAccessToken or Oauth, matched case-insensitively."
  }
  validation {
    condition     = alltrue([for control in values(var.automation_source_controls) : control.security_token_version >= 1 && floor(control.security_token_version) == control.security_token_version])
    error_message = "Every source-control security_token_version must be a positive integer."
  }
}

variable "automation_variable_bools" {
  type = map(object({
    value_version = optional(number, 1)
    name          = string
    value         = optional(bool, true)
    description   = optional(string)
    encrypted     = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Variables of type `Bool` which should be created in this Automation Account.
    `value_version` - (Optional) A positive integer, default 1. Increment when changing an encrypted value; encrypted values use a write-only request body.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable. Defaults to `true`.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.

  Example Input:
  ```terraform
  automation_variable_bools = {
    "mybool" = {
      name        = "mybool"
      value       = true
      description = "My Bool Variable"
      encrypted   = false
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true
}

variable "automation_variable_datetimes" {
  type = map(object({
    value_version = optional(number, 1)
    name          = string
    value         = optional(string)
    description   = optional(string)
    encrypted     = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Variables of type `DateTime` which should be created in this Automation Account.
    `value_version` - (Optional) A positive integer, default 1. Increment when changing an encrypted value; the request value is write-only, but the time_static serialization helper retains the timestamp in protected state.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.

  Example Input:
  ```terraform
  automation_variable_datetimes = {
    "mydatetime" = {
      name        = "mydatetime"
      value       = "2023-10-01T00:00:00Z"
      description = "My DateTime Variable"
      encrypted   = false
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true
}

variable "automation_variable_ints" {
  type = map(object({
    value_version = optional(number, 1)
    name          = string
    value         = optional(number)
    description   = optional(string)
    encrypted     = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Variables of type `Int` which should be created in this Automation Account.
    `value_version` - (Optional) A positive integer, default 1. Increment when changing an encrypted value; encrypted values use a write-only request body.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.

  Example Input:
  ```terraform
  automation_variable_ints = {
    "myint" = {
      name        = "myint"
      value       = 123
      description = "My Int Variable"
      encrypted   = false
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true
}

variable "automation_variable_objects" {
  type = map(object({
    value_version = optional(number, 1)
    name          = string
    value         = optional(string)
    description   = optional(string)
    encrypted     = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Variables of type `Object` which should be created in this Automation Account.
    `value_version` - (Optional) A positive integer, default 1. Increment when changing an encrypted value; encrypted values use a write-only request body.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.

  Example Input:
  ```terraform
  automation_variable_objects = {
    "myobject" = {
      name        = "myobject"
      value       = "{\"key\":\"value\"}"
      description = "My Object Variable"
      encrypted   = false
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true
}

variable "automation_variable_strings" {
  type = map(object({
    value_version = optional(number, 1)
    name          = string
    value         = optional(string)
    description   = optional(string)
    encrypted     = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
  A list of Automation Variables of type `String` which should be created in this Automation Account.
    `value_version` - (Optional) A positive integer, default 1. Increment when changing an encrypted value; encrypted values use a write-only request body.
    `name` - (Required) The name of the Variable.
    `value` - (Optional) The value of the Variable.
    `description` - (Optional) A description for this Variable.
    `encrypted` - (Optional) Whether the Variable is encrypted. Defaults to `false`.

  Example Input:
  ```terraform
  automation_variable_strings = {
    "mystring" = {
      name        = "mystring"
      value       = "My String Variable"
      description = "My String Variable"
      encrypted   = false
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true
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
  }))
  default     = {}
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
    }
  }
  ```
  EOT
  nullable    = false
}

variable "automation_webhooks" {
  type = map(object({
    name                = string
    expiry_time         = string
    enabled             = optional(bool, true)
    runbook_key         = string
    run_on_worker_group = optional(string)
    parameters          = optional(map(string))
    uri                 = optional(string, null)
    uri_version         = optional(number, 1)
  }))
  default     = {}
  description = <<-EOT
  A list of webhook to be created for an Automation runbook in this Automation Account.
    `name` - (Required) Specifies the name of the Webhook. Changing this forces a new resource to be created.
    `expiry_time` - (Required) Timestamp when the webhook expires. Changing this forces a new resource to be created.
    `enabled` - (Optional) Controls if Webhook is enabled. Defaults to `true`.
    `runbook_key` - (Required) The reference key of the Automation Runbook to execute by Webhook.
    `run_on_worker_group` - (Optional) Name of the hybrid worker group the Webhook job will run on.
    `parameters` - (Optional) Map of input parameters passed to runbook.
    `uri` - (Optional) The URI of the webhook. Changing this forces a new resource to be created.
    `uri_version` - (Optional) A positive integer, default 1. Increment to rotate a generated URI or send a changed supplied URI. Generated URIs are exposed through the sensitive `automation_webhook_uris` output and are retained in protected Terraform state.

  Example Input:
  ```terraform
  automation_webhooks = {
    "mywebhook" = {
      name                = "mywebhook"
      expiry_time         = "2023-12-31T23:59:59Z"
      enabled             = true
      runbook_key         = "auto_runbook_key1"
      run_on_worker_group = "mygroup"
      parameters          = {"param1"="value1"}
      uri                 = "https://example.com/mywebhook"
    }
  }
  ```
  EOT
  nullable    = false
  sensitive   = true

  validation {
    condition = alltrue([
      for webhook in values(var.automation_webhooks) :
      contains(keys(var.automation_runbooks), webhook.runbook_key)
    ])
    error_message = "Each webhook runbook_key must reference an existing automation_runbooks entry."
  }
  validation {
    condition = alltrue([
      for webhook in values(var.automation_webhooks) :
      webhook.uri_version >= 1 && floor(webhook.uri_version) == webhook.uri_version
    ])
    error_message = "Each webhook uri_version must be a positive integer."
  }
}

variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = "Customer-managed encryption key. Supply the encryption identity here and in managed_identities.user_assigned_resource_ids. Omitting key_version follows key rotation. Do not combine this input with legacy encryption using Microsoft.KeyVault."

  validation {
    condition     = var.customer_managed_key == null || can(provider::azapi::parse_resource_id("Microsoft.KeyVault/vaults", var.customer_managed_key.key_vault_resource_id))
    error_message = "`customer_managed_key.key_vault_resource_id` must be a valid Azure Key Vault resource ID."
  }
  validation {
    condition     = var.customer_managed_key == null || var.customer_managed_key.user_assigned_identity == null || can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", var.customer_managed_key.user_assigned_identity.resource_id))
    error_message = "`customer_managed_key.user_assigned_identity.resource_id` must be a valid user-assigned managed identity resource ID."
  }
  validation {
    condition     = var.customer_managed_key == null || var.encryption.key_source == "Microsoft.Automation"
    error_message = "Use either customer_managed_key or legacy encryption using Microsoft.KeyVault, not both."
  }
}

variable "diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
    logs = optional(set(object({
      category       = optional(string, null)
      category_group = optional(string, null)
      enabled        = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    metrics = optional(set(object({
      category = optional(string, null)
      enabled  = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `logs` - (Optional) A set of log entries to send to the destination. Each entry has the following attributes:
  - `category` - (Optional) The name of a specific log category to enable. Mutually exclusive with `category_group`.
  - `category_group` - (Optional) The name of a log category group to enable (for example, `allLogs` or `audit`). Mutually exclusive with `category`.
  - `enabled` - (Optional) Whether the log entry is enabled. Defaults to `true`.
  - `retention_policy` - (Optional) The retention policy for the log entry.
    - `days` - (Optional) The retention period in days. Defaults to `0` (retain indefinitely).
    - `enabled` - (Optional) Whether the retention policy is enabled. Defaults to `false`.
- `metrics` - (Optional) A set of metric entries to send to the destination. Each entry has the following attributes:
  - `category` - (Optional) The name of the metric entry to enable.
  - `enabled` - (Optional) Whether the metric entry is enabled. Defaults to `true`.
  - `retention_policy` - (Optional) The retention policy for the metric entry, with the same `days` and `enabled` attributes as `logs.retention_policy`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings : alltrue([
        for l in v.logs : (l.category != null) != (l.category_group != null)
      ])
    ])
    error_message = "Each log entry must set exactly one of `category` or `category_group`."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.workspace_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.OperationalInsights/workspaces", v.workspace_resource_id))
    ])
    error_message = "Each `workspace_resource_id` must be a valid Log Analytics workspace resource ID, or null."
  }
  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.storage_account_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.Storage/storageAccounts", v.storage_account_resource_id))
    ])
    error_message = "Each `storage_account_resource_id` must be a valid storage account resource ID, or null."
  }
  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.event_hub_authorization_rule_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.EventHub/namespaces/authorizationRules", v.event_hub_authorization_rule_resource_id))
    ])
    error_message = "Each `event_hub_authorization_rule_resource_id` must be a valid Event Hub namespace authorization rule resource ID, or null."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "encryption" {
  type = object({
    key_source                = string
    key_vault_key_id          = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default = {
    key_source = "Microsoft.Automation"
  }
  description = <<-EOT
  Legacy encryption input retained for migration compatibility. Prefer `customer_managed_key`.
  - `key_source` - (Required) The source of the encryption key. Default value is `Microsoft.Automation`. Possible values are `Microsoft.KeyVault` or `Microsoft.Automation`.
  - `key_vault_key_id` - (Optional) The ID of the Key Vault Key which should be used to Encrypt the data in this Automation Account. Required if `key_source` is set to `Microsoft.KeyVault`.
  - `user_assigned_identity_id` - (Optional) The User Assigned Managed Identity ID to be used for accessing the Customer Managed Key for encryption. Required if `key_source` is set to `Microsoft.KeyVault`.
  EOT
  nullable    = false

  validation {
    condition     = contains(["Microsoft.Automation", "Microsoft.KeyVault"], var.encryption.key_source)
    error_message = "The key source must be either `Microsoft.Automation` or `Microsoft.KeyVault`."
  }
  validation {
    condition     = var.encryption.key_source != "Microsoft.KeyVault" || (var.encryption.key_vault_key_id != null && var.encryption.user_assigned_identity_id != null)
    error_message = "If `key_source` is set to `Microsoft.KeyVault`, both `key_vault_key_id` and `user_assigned_identity_id` must be provided."
  }
  validation {
    condition     = var.encryption.user_assigned_identity_id == null || can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", var.encryption.user_assigned_identity_id))
    error_message = "`encryption.user_assigned_identity_id` must be a valid user-assigned managed identity resource ID, or null."
  }
  validation {
    condition     = var.encryption.key_vault_key_id == null || can(regex("^https://[^/]+/keys/[^/]+(/[^/]+)?$", var.encryption.key_vault_key_id))
    error_message = "`encryption.key_vault_key_id` must be a Key Vault key URI, optionally including a version."
  }
}

variable "ignore_body_changes" {
  type = object({
    authorization_locks                                                                = optional(list(string), [])
    authorization_role_assignments                                                     = optional(list(string), [])
    automation_automation_accounts                                                     = optional(list(string), [])
    automation_automation_accounts_certificates                                        = optional(list(string), [])
    automation_automation_accounts_connections                                         = optional(list(string), [])
    automation_automation_accounts_job_schedules                                       = optional(list(string), [])
    automation_automation_accounts_credentials                                         = optional(list(string), [])
    automation_automation_accounts_hybrid_runbook_worker_groups                        = optional(list(string), [])
    automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers = optional(list(string), [])
    automation_automation_accounts_modules                                             = optional(list(string), [])
    automation_automation_accounts_schedules                                           = optional(list(string), [])
    automation_automation_accounts_variables                                           = optional(list(string), [])
    automation_automation_accounts_watchers                                            = optional(list(string), [])
    automation_automation_accounts_webhooks                                            = optional(list(string), [])
    automation_automation_accounts_power_shell72_modules                               = optional(list(string), [])
    automation_automation_accounts_python3_packages                                    = optional(list(string), [])
    automation_automation_accounts_runbooks                                            = optional(list(string), [])
    automation_automation_accounts_source_controls                                     = optional(list(string), [])
    insights_diagnostic_settings                                                       = optional(list(string), [])
    network_private_endpoints                                                          = optional(list(string), [])
    network_private_endpoints_private_dns_zone_groups                                  = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths to ignore for module-owned resources. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure until the path is removed.
Non-empty values require Terraform 1.11 or later.

- `authorization_locks` - Paths ignored on account and private endpoint locks.
- `authorization_role_assignments` - Paths ignored on account and private endpoint role assignments.
- `automation_automation_accounts_connections` - Paths ignored on Automation Account connections.
- `automation_automation_accounts_job_schedules` - Paths ignored on Automation Account job schedules.
- `automation_automation_accounts` - Paths ignored on Automation Accounts.
- `automation_automation_accounts_certificates` - Paths ignored on Automation Account certificates.
- `automation_automation_accounts_credentials` - Paths ignored on Automation Account credentials.
- `automation_automation_accounts_hybrid_runbook_worker_groups` - Paths ignored on Automation Account hybrid runbook worker groups.
- `automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers` - Paths ignored on Automation Account hybrid runbook workers.
- `automation_automation_accounts_modules` - Paths ignored on Automation Account modules.
- `automation_automation_accounts_schedules` - Paths ignored on Automation Account schedules.
- `automation_automation_accounts_variables` - Paths ignored on Automation Account variables.
- `automation_automation_accounts_watchers` - Paths ignored on Automation Account watchers.
- `automation_automation_accounts_webhooks` - Paths ignored on Automation Account webhooks.
- `automation_automation_accounts_power_shell72_modules` - Paths ignored on Automation Account PowerShell 7.2 modules.
- `automation_automation_accounts_python3_packages` - Paths ignored on Automation Account Python 3 packages.
- `automation_automation_accounts_runbooks` - Paths ignored on Automation Account runbooks.
- `automation_automation_accounts_source_controls` - Paths ignored on Automation Account source controls.
- `insights_diagnostic_settings` - Paths ignored on insights diagnostic settings.
- `network_private_endpoints` - Paths ignored on network private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Paths ignored on network private endpoint private DNS zone groups.
DESCRIPTION
  nullable    = false
}

variable "local_authentication_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether requests using non-AAD authentication are blocked. Defaults to `true`."
}

variable "lock" {
  type = object({
    kind  = string
    name  = optional(string, null)
    notes = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  - `notes` - (Optional) Notes about the lock. This value maps to `Microsoft.Authorization/locks.properties.notes`.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for id in var.managed_identities.user_assigned_resource_ids :
      can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", id))
    ])
    error_message = "Each entry in `managed_identities.user_assigned_resource_ids` must be a valid user-assigned managed identity resource ID."
  }
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      name                                   = optional(string, null)
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
      kind  = string
      name  = optional(string, null)
      notes = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = optional(string, null)
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
      member_name        = optional(string)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the Automation Account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
  - `name` - (Optional) The name of the role assignment. If not set, a random UUID will be generated. Changing this forces the creation of a new resource.
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
- `lock` - (Optional) The lock to apply to the private endpoint. Omit it, or set it to `null`, to create no lock.
  - `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
  - `name` - (Optional) The name of the lock. One is generated from the private endpoint name if not set. Changing this forces the creation of a new resource.
  - `notes` - (Optional) Notes about the lock. This value maps to `Microsoft.Authorization/locks.properties.notes`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - The private link sub-resource name. Required for this multi-service resource; specify `Webhook` or `DSCAndHybridWorker`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The name of the resource group where the private endpoint resources will be deployed. Defaults to the Automation Accounts's resource group.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
  - `member_name` - (Optional) The private IP configuration member name.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.private_endpoints :
      can(provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks/subnets", v.subnet_resource_id))
    ])
    error_message = "Each `private_endpoints[*].subnet_resource_id` must be a valid subnet resource ID."
  }
  validation {
    condition = alltrue(flatten([
      for _, v in var.private_endpoints : [
        for id in v.private_dns_zone_resource_ids :
        can(provider::azapi::parse_resource_id("Microsoft.Network/privateDnsZones", id))
      ]
    ]))
    error_message = "Each entry in `private_endpoints[*].private_dns_zone_resource_ids` must be a valid private DNS zone resource ID."
  }
  validation {
    condition = alltrue(flatten([
      for _, v in var.private_endpoints : [
        for _, asg in v.application_security_group_associations :
        can(provider::azapi::parse_resource_id("Microsoft.Network/applicationSecurityGroups", asg))
      ]
    ]))
    error_message = "Each value in `private_endpoints[*].application_security_group_associations` must be a valid application security group resource ID."
  }
  validation {
    condition = alltrue(flatten([
      for _, v in var.private_endpoints : [
        for _, ra in v.role_assignments :
        ra.delegated_managed_identity_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", ra.delegated_managed_identity_resource_id))
      ]
    ]))
    error_message = "Each `private_endpoints[*].role_assignments[*].delegated_managed_identity_resource_id` must be a valid user-assigned managed identity resource ID, or null."
  }
  validation {
    condition     = alltrue([for _, v in var.private_endpoints : v.lock == null ? true : contains(["CanNotDelete", "ReadOnly"], v.lock.kind)])
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
  validation {
    condition     = alltrue([for _, v in var.private_endpoints : v.subresource_name == null ? false : contains(["Webhook", "DSCAndHybridWorker"], v.subresource_name)])
    error_message = "Each `private_endpoints[*].subresource_name` is required for the multi-service Automation Account and must be either `Webhook` or `DSCAndHybridWorker`."
  }
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether public network access is allowed for the automation account. Defaults to `false`."
}

variable "resource_types" {
  type = object({
    authorization_locks                                                                = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments                                                     = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    automation_automation_accounts                                                     = optional(string, "Microsoft.Automation/automationAccounts@2024-10-23")
    automation_automation_accounts_certificates                                        = optional(string, "Microsoft.Automation/automationAccounts/certificates@2024-10-23")
    automation_automation_accounts_connections                                         = optional(string, "Microsoft.Automation/automationAccounts/connections@2024-10-23")
    automation_automation_accounts_job_schedules                                       = optional(string, "Microsoft.Automation/automationAccounts/jobSchedules@2024-10-23")
    automation_automation_accounts_credentials                                         = optional(string, "Microsoft.Automation/automationAccounts/credentials@2024-10-23")
    automation_automation_accounts_hybrid_runbook_worker_groups                        = optional(string, "Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups@2024-10-23")
    automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers = optional(string, "Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups/hybridRunbookWorkers@2024-10-23")
    automation_automation_accounts_modules                                             = optional(string, "Microsoft.Automation/automationAccounts/modules@2024-10-23")
    automation_automation_accounts_schedules                                           = optional(string, "Microsoft.Automation/automationAccounts/schedules@2024-10-23")
    automation_automation_accounts_variables                                           = optional(string, "Microsoft.Automation/automationAccounts/variables@2024-10-23")
    automation_automation_accounts_watchers                                            = optional(string, "Microsoft.Automation/automationAccounts/watchers@2024-10-23")
    automation_automation_accounts_webhooks                                            = optional(string, "Microsoft.Automation/automationAccounts/webhooks@2024-10-23")
    automation_automation_accounts_power_shell72_modules                               = optional(string, "Microsoft.Automation/automationAccounts/powerShell72Modules@2023-11-01")
    automation_automation_accounts_python3_packages                                    = optional(string, "Microsoft.Automation/automationAccounts/python3Packages@2024-10-23")
    automation_automation_accounts_runbooks                                            = optional(string, "Microsoft.Automation/automationAccounts/runbooks@2024-10-23")
    automation_automation_accounts_source_controls                                     = optional(string, "Microsoft.Automation/automationAccounts/sourceControls@2024-10-23")
    insights_diagnostic_settings                                                       = optional(string, "Microsoft.Insights/diagnosticSettings@2021-05-01-preview")
    network_private_endpoints                                                          = optional(string, "Microsoft.Network/privateEndpoints@2025-05-01")
    network_private_endpoints_private_dns_zone_groups                                  = optional(string, "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `authorization_locks` - Resource type and API version for account and private endpoint locks.
- `authorization_role_assignments` - Resource type and API version for account and private endpoint role assignments.
- `automation_automation_accounts` - Resource type and API version for Automation Accounts.
- `automation_automation_accounts_certificates` - Resource type and API version for Automation Account certificates.
- `automation_automation_accounts_connections` - Resource type and API version for Automation Account connections.
- `automation_automation_accounts_job_schedules` - Resource type and API version for Automation Account job schedules.
- `automation_automation_accounts_credentials` - Resource type and API version for Automation Account credentials.
- `automation_automation_accounts_hybrid_runbook_worker_groups` - Resource type and API version for Automation Account hybrid runbook worker groups.
- `automation_automation_accounts_hybrid_runbook_worker_groups_hybrid_runbook_workers` - Resource type and API version for Automation Account hybrid runbook workers.
- `automation_automation_accounts_webhooks` - Resource type and API version for Automation Account webhooks.
- `automation_automation_accounts_watchers` - Resource type and API version for Automation Account watchers.
- `automation_automation_accounts_modules` - Resource type and API version for Automation Account modules.
- `automation_automation_accounts_variables` - Resource type and API version for Automation Account variables.
- `automation_automation_accounts_schedules` - Resource type and API version for Automation Account schedules.
- `automation_automation_accounts_source_controls` - Resource type and API version for Automation Account source controls.
- `automation_automation_accounts_power_shell72_modules` - Resource type and API version for Automation Account PowerShell 7.2 modules.
- `automation_automation_accounts_python3_packages` - Resource type and API version for Automation Account Python 3 packages.
- `automation_automation_accounts_runbooks` - Resource type and API version for Automation Account runbooks.
- `insights_diagnostic_settings` - Resource type and API version for diagnostic settings.
- `network_private_endpoints` - Resource type and API version for network private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Resource type and API version for network private endpoints private DNS zone groups.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default = {
    error_message_regex = ["ScopeLocked"]
  }
  description = <<DESCRIPTION
Retry configuration applied to every supported AzAPI resource declared by the module. By default, retries ScopeLocked errors during lock removal propagation. Set to null for provider defaults.

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry.
- `interval_seconds` - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the Automation Account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the role assignment. If not set, a random UUID will be generated. Changing this forces the creation of a new resource.
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
  DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.role_assignments :
      v.delegated_managed_identity_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", v.delegated_managed_identity_resource_id))
    ])
    error_message = "Each `role_assignments[*].delegated_managed_identity_resource_id` must be a valid user-assigned managed identity resource ID, or null."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
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
  Per-operation timeouts for every AzAPI resource declared by this module.

  - `create` - (Defaults to 30 minutes) Used when creating the Automation Account.
  - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Account.
  - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Account.
  - `update` - (Defaults to 30 minutes) Used when updating the Automation Account.
  EOT
}
