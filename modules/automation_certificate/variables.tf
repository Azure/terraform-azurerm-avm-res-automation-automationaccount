variable "automation_certificate_automation_account_name" {
  type        = string
  description = "(Required) The name of the automation account in which the Certificate is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_certificate_base64" {
  type        = string
  description = "(Required) Base64 encoded value of the certificate. Changing this forces a new resource to be created."
  nullable    = false
  sensitive   = true
}

variable "automation_certificate_name" {
  type        = string
  description = "(Required) Specifies the name of the Certificate. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_certificate_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Certificate is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_certificate_description" {
  type        = string
  default     = null
  description = "(Optional) The description of this Automation Certificate."
}

variable "automation_certificate_exportable" {
  type        = bool
  default     = null
  description = "(Optional) The is exportable flag of the certificate."
}

variable "automation_certificate_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Automation Certificate.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Certificate.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Certificate.
 - `update` - (Defaults to 30 minutes) Used when updating the Automation Certificate.
EOT
}
