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

variable "automation_certificate" {
  type        = object({
    name        = string
    base64      = string
    resource_group_name = string
    automation_account_name = string
    description = optional(string)
    exportable  = optional(bool,false)
    timeouts    = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  description = <<-EOT
  A list of Automation Certificates which should be created in this Automation Account.
    `name` - (Required) The name of the Certificate.
    `base64` - (Required) The base64 encoded value of the Certificate.
    `resource_group_name` - (Required) The name of the resource group in which the Certificate is created.
    `automation_account_name` - (Required) The name of the automation account in which the Certificate is created.
    `description` - (Optional) A description for this Certificate.
    `exportable` - (Optional) Whether the Certificate is exportable. Defaults to `false`.
    `timeouts` - (Optional) The timeouts block.
EOT
  nullable    = false
}

variable "automation_connection" {
  type        = object({
    name        = string
    resource_group_name = string
    automation_account_name = string
    type        = string
    values      = map(string)
    description = optional(string)
    timeouts    = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  description = <<-EOT
  A list of Automation Connections which should be created in this Automation Account.
    `name` - (Required) The name of the Connection.
    `resource_group_name` - (Required) The name of the resource group in which the Connection is created.
    `automation_account_name` - (Required) The name of the automation account in which the Connection is created.
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


