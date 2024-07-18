variable "automation_schedule_automation_account_name" {
  type        = string
  description = "(Required) The name of the automation account in which the Schedule is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_schedule_frequency" {
  type        = string
  description = "(Required) The frequency of the schedule."
  nullable    = false
}

variable "automation_schedule_name" {
  type        = string
  description = "(Required) Specifies the name of the Schedule. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_schedule_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Schedule is created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "automation_schedule_description" {
  type        = string
  default     = null
  description = "(Optional) A description for this Schedule."
}

variable "automation_schedule_expiry_time" {
  type        = string
  default     = null
  description = "(Optional) The end time of the schedule."
}

variable "automation_schedule_interval" {
  type        = number
  default     = null
  description = "(Optional) The number of `frequency`s between runs. Only valid when frequency is `Day`, `Hour`, `Week`, or `Month` and defaults to `1`."
}

variable "automation_schedule_month_days" {
  type        = set(number)
  default     = null
  description = "(Optional) List of days of the month that the job should execute on. Must be between `1` and `31`. `-1` for last day of the month. Only valid when frequency is `Month`."
}

variable "automation_schedule_monthly_occurrence" {
  type = object({
    day        = string
    occurrence = number
  })
  default     = null
  description = <<-EOT
 - `day` - (Required) Day of the occurrence. Must be one of `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`.
 - `occurrence` - (Required) Occurrence of the week within the month. Must be between `1` and `5`. `-1` for last week within the month.
EOT
}

variable "automation_schedule_start_time" {
  type        = string
  default     = null
  description = "(Optional) Start time of the schedule. Must be at least five minutes in the future. Defaults to seven minutes in the future from the time the resource is created."
}

variable "automation_schedule_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Automation Schedule.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Automation Schedule.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Automation Schedule.
 - `update` - (Defaults to 30 minutes) Used when updating the Automation Schedule.
EOT
}

variable "automation_schedule_timezone" {
  type        = string
  default     = null
  description = "(Optional) The timezone of the start time. Defaults to `Etc/UTC`. For possible values see: <https://docs.microsoft.com/en-us/rest/api/maps/timezone/gettimezoneenumwindows>"
}

variable "automation_schedule_week_days" {
  type        = set(string)
  default     = null
  description = "(Optional) List of days of the week that the job should execute on. Only valid when frequency is `Week`. Possible values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday` and `Sunday`."
}
