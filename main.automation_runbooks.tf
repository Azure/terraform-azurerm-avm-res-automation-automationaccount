resource "azurerm_automation_runbook" "this" {
  for_each = var.automation_runbooks != null ? var.automation_runbooks : {}

  automation_account_name  = azurerm_automation_account.this.name
  location                 = azurerm_automation_account.this.location
  log_progress             = each.value.log_progress
  log_verbose              = each.value.log_verbose
  name                     = each.value.name
  resource_group_name      = azurerm_automation_account.this.resource_group_name
  runbook_type             = each.value.runbook_type
  content                  = each.value.content
  description              = each.value.description
  log_activity_trace_level = each.value.log_activity_trace_level
  tags                     = each.value.tags

  dynamic "draft" {
    for_each = each.value.draft == null ? [] : [each.value.draft]

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
  # Need to understand how Job_schedule needs to be configured.
  # dynamic "job_schedule" {
  #   for_each = each.value.job_schedule == null ? [] : [each.value.job_schedule]

  #   content {
  #     parameters    = job_schedule.value.parameters
  #     run_on        = job_schedule.value.run_on
  #     schedule_name = job_schedule.value.schedule_name
  #   }
  # }
  dynamic "publish_content_link" {
    for_each = each.value.publish_content_link == null ? [] : [each.value.publish_content_link]

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
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

