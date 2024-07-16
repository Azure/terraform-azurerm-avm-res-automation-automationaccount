resource "azurerm_automation_runbook" "this" {
  automation_account_name  = var.automation_runbook_automation_account_name
  location                 = var.automation_runbook_location
  log_progress             = var.automation_runbook_log_progress
  log_verbose              = var.automation_runbook_log_verbose
  name                     = var.automation_runbook_name
  resource_group_name      = var.automation_runbook_resource_group_name
  runbook_type             = var.automation_runbook_runbook_type
  content                  = var.automation_runbook_content
  description              = var.automation_runbook_description
  log_activity_trace_level = var.automation_runbook_log_activity_trace_level
  tags                     = var.automation_runbook_tags

  dynamic "draft" {
    for_each = var.automation_runbook_draft == null ? [] : [var.automation_runbook_draft]
    content {
      edit_mode_enabled = draft.value.edit_mode_enabled
      output_types      = draft.value.output_types

      dynamic "content_link" {
        for_each = draft.value.content_link == null ? [] : [draft.value.content_link]
        content {
          uri     = content_link.value.uri
          version = content_link.value.version

          dynamic "hash" {
            for_each = content_link.value.hash == null ? [] : [content_link.value.hash]
            content {
              algorithm = hash.value.algorithm
              value     = hash.value.value
            }
          }
        }
      }
      dynamic "parameters" {
        for_each = draft.value.parameters == null ? [] : draft.value.parameters
        content {
          key           = parameters.value.key
          type          = parameters.value.type
          default_value = parameters.value.default_value
          mandatory     = parameters.value.mandatory
          position      = parameters.value.position
        }
      }
    }
  }
  dynamic "job_schedule" {
    for_each = var.automation_runbook_job_schedule == null ? [] : var.automation_runbook_job_schedule
    content {
      job_schedule_id = job_schedule.value.job_schedule_id
      parameters      = job_schedule.value.parameters
      run_on          = job_schedule.value.run_on
      schedule_name   = job_schedule.value.schedule_name
    }
  }
  dynamic "publish_content_link" {
    for_each = var.automation_runbook_publish_content_link == null ? [] : [var.automation_runbook_publish_content_link]
    content {
      uri     = publish_content_link.value.uri
      version = publish_content_link.value.version

      dynamic "hash" {
        for_each = publish_content_link.value.hash == null ? [] : [publish_content_link.value.hash]
        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.automation_runbook_timeouts == null ? [] : [var.automation_runbook_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

