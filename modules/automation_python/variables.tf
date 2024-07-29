variable "automation_python3_package_automation_account_name" {
  type        = string
  description = "(Required) The name of the automation account in which the Python3 Package is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_python3_package_content_uri" {
  type        = string
  description = "(Required) The URL of the python package. Changing this forces a new Automation Python3 Package to be created."
  nullable    = false
}

variable "automation_python3_package_name" {
  type        = string
  description = "(Required) The name which should be used for this Automation Python3 Package. Changing this forces a new Automation Python3 Package to be created."
  nullable    = false
}

variable "automation_python3_package_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Python3 Package is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_python3_package_content_version" {
  type        = string
  default     = null
  description = "(Optional) Specify the version of the python3 package. The value should meet the system.version class format like `1.1.1`. Changing this forces a new Automation Python3 Package to be created."
}

variable "automation_python3_package_hash_algorithm" {
  type        = string
  default     = null
  description = "(Optional) Specify the hash algorithm used to hash the content of the python3 package. Changing this forces a new Automation Python3 Package to be created."
}

variable "automation_python3_package_hash_value" {
  type        = string
  default     = null
  description = "(Optional) Specity the hash value of the content. Changing this forces a new Automation Python3 Package to be created."
}

variable "automation_python3_package_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Automation Python3 Package."
}

variable "automation_python3_package_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Automation Python3 Package.
 - `delete` - (Defaults to 10 minutes) Used when deleting the Automation Python3 Package.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Python3 Package.
 - `update` - (Defaults to 10 minutes) Used when updating the Automation Python3 Package.
EOT
}
