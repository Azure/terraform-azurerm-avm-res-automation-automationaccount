variable "automation_runbook_automation_account_name" {
  type        = string
  description = "(Required) The name of the automation account in which the Runbook is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_runbook_location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_runbook_log_progress" {
  type        = bool
  description = "(Required) Progress log option."
  nullable    = false
}

variable "automation_runbook_log_verbose" {
  type        = bool
  description = "(Required) Verbose log option."
  nullable    = false
}

variable "automation_runbook_name" {
  type        = string
  description = "(Required) Specifies the name of the Runbook. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_runbook_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Runbook is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_runbook_runbook_type" {
  type        = string
  description = "(Required) The type of the runbook"
  nullable    = false
}

variable "automation_runbook_content" {
  type        = string
  default     = null
  description = "(Optional) The desired content of the runbook."
}

variable "automation_runbook_description" {
  type        = string
  default     = null
  description = "(Optional) A description for this credential."
}

variable "automation_runbook_draft" {
  type = object({
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
  })
  default     = null
  description = <<-EOT
 - `edit_mode_enabled` - (Optional) Whether the draft in edit mode.
 - `output_types` - (Optional) Specifies the output types of the runbook.

 ---
 `content_link` block supports the following:
 - `uri` - 
 - `version` - 

 ---
 `hash` block supports the following:
 - `algorithm` - (Required) Specifies the hash algorithm used to hash the content.
 - `value` - (Required) Specifies the expected hash value of the content.

 ---
 `parameters` block supports the following:
 - `default_value` - (Optional) Specifies the default value of the parameter.
 - `key` - (Required) The name of the parameter.
 - `mandatory` - (Optional) Whether this parameter is mandatory.
 - `position` - (Optional) Specifies the position of the parameter.
 - `type` - (Required) Specifies the type of this parameter.
EOT
}

variable "automation_runbook_job_schedule" {
  type = set(object({
    job_schedule_id = string
    parameters      = map(string)
    run_on          = string
    schedule_name   = string
  }))
  default     = null
  description = <<-EOT
 - `job_schedule_id` - 
 - `parameters` - (Optional) A map of key/value pairs corresponding to the arguments that can be passed to the Runbook.
 - `run_on` - (Optional) Name of a Hybrid Worker Group the Runbook will be executed on.
 - `schedule_name` - (Required) The name of the Schedule.
EOT
}

variable "automation_runbook_log_activity_trace_level" {
  type        = number
  default     = null
  description = "(Optional) Specifies the activity-level tracing options of the runbook, available only for Graphical runbooks. Possible values are `0` for None, `9` for Basic, and `15` for Detailed. Must turn on Verbose logging in order to see the tracing."
}

variable "automation_runbook_publish_content_link" {
  type = object({
    uri     = string
    version = optional(string)
    hash = optional(object({
      algorithm = string
      value     = string
    }))
  })
  default     = null
  description = <<-EOT
 - `uri` - (Required) The URI of the runbook content.
 - `version` - (Optional) Specifies the version of the content

 ---
 `hash` block supports the following:
 - `algorithm` - (Required) Specifies the hash algorithm used to hash the content.
 - `value` - (Required) Specifies the expected hash value of the content.
EOT
}

variable "automation_runbook_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "automation_runbook_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Automation Runbook.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Runbook.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Runbook.
 - `update` - (Defaults to 30 minutes) Used when updating the Automation Runbook.
EOT
}
