variable "automation_connection_automation_account_name" {
  type        = string
  description = "(Required) The name of the automation account in which the Connection is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_connection_name" {
  type        = string
  description = "(Required) Specifies the name of the Connection. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_connection_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Connection is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_connection_type" {
  type        = string
  description = "(Required) The type of the Connection"
  nullable    = false
}

variable "automation_connection_values" {
  type        = map(string)
  description = "(Required) A mapping of key value pairs passed to the connection. Different `type` needs different parameters in the `values`. Builtin types have required field values as below:"
  nullable    = false
}

variable "automation_connection_description" {
  type        = string
  default     = null
  description = "(Optional) A description for this Connection."
}

variable "automation_connection_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Automation Connection.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Connection.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Connection.
 - `update` - (Defaults to 30 minutes) Used when updating the Automation Connection.
EOT
}
