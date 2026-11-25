mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "random" {}
mock_provider "time" {
  mock_resource "time_static" {
    defaults = {
      rfc3339 = "2027-01-01T00:00:00Z"
    }
  }
}

override_resource {
  target          = azapi_resource.this
  override_during = plan
  values = {
    id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test"
    output = { properties = { automationHybridServiceUrl = "https://example.com/hybrid" } }
  }
}

variables {
  name             = "automation-test"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg"
  sku              = { name = "Basic" }
  enable_telemetry = false
  automation_runbooks = {
    cleanup = {
      name                 = "cleanup-runbook"
      runbook_type         = "PowerShell"
      log_progress         = false
      log_verbose          = false
      publish_content_link = { uri = "https://example.com/cleanup.ps1" }
    }
  }
  automation_schedules = {
    daily = {
      name      = "daily-schedule"
      frequency = "Day"
    }
    hourly = {
      name      = "hourly-schedule"
      frequency = "Hour"
    }
  }
}

run "creates_standalone_and_inline_jobs" {
  command = plan

  variables {
    timeouts = { create = "40m" }
    retry = {
      error_message_regex = ["Conflict"]
      interval_seconds    = 5
    }
    automation_job_schedules = {
      standalone = {
        runbook_key  = "cleanup"
        schedule_key = "daily"
        parameters   = { environment = "test" }
        run_on       = "worker-group"
        timeouts     = { create = "10m" }
      }
    }
    automation_runbooks = {
      cleanup = {
        name                 = "cleanup-runbook"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/cleanup.ps1" }
        job_schedule = [{
          schedule_key = "hourly"
        }]
      }
    }
  }

  assert {
    condition = (
      length(azapi_resource.automation_account_job_schedules) == 2 &&
      contains(keys(azapi_resource.automation_account_job_schedules), "standalone") &&
      contains(keys(azapi_resource.automation_account_job_schedules), jsonencode(["runbook", "cleanup", "hourly"]))
    )
    error_message = "Standalone keys must be preserved and inline keys must identify their runbook and schedule."
  }

  assert {
    condition = (
      azapi_resource.automation_account_job_schedules["standalone"].body.properties.runbook.name == "cleanup-runbook" &&
      azapi_resource.automation_account_job_schedules["standalone"].body.properties.schedule.name == "daily-schedule" &&
      azapi_resource.automation_account_job_schedules["standalone"].body.properties.parameters.environment == "test" &&
      azapi_resource.automation_account_job_schedules["standalone"].body.properties.runOn == "worker-group" &&
      azapi_resource.automation_account_job_schedules["standalone"].parent_id == azapi_resource.this.id
    )
    error_message = "The ARM job schedule must preserve its names, parameters, worker group, and account scope."
  }

  assert {
    condition = (
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].body.properties.schedule.name == "hourly-schedule" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].body.properties.runOn == null &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].body.properties.parameters == null
    )
    error_message = "Inline jobs must resolve their schedule and allow omitted optional fields."
  }

  assert {
    condition = alltrue([
      for job in values(azapi_resource.automation_account_job_schedules) :
      can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", job.name))
    ])
    error_message = "New job schedule ARM names must be GUIDs."
  }

  assert {
    condition = (
      azapi_resource.automation_account_job_schedules["standalone"].timeouts.create == "10m" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].timeouts.create == "40m" &&
      azapi_resource.automation_account_job_schedules["standalone"].retry.interval_seconds == 5
    )
    error_message = "Per-job timeouts must override module defaults, with retries propagated."
  }
}

run "imports_existing_job_schedule_guids" {
  command = plan

  override_resource {
    target          = azapi_resource.automation_account_job_schedules["standalone"]
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test/jobSchedules/11111111-1111-1111-1111-111111111111"
    }
  }

  override_resource {
    target          = azapi_resource.automation_account_job_schedules["[\"runbook\",\"cleanup\",\"hourly\"]"]
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/automation-rg/providers/Microsoft.Automation/automationAccounts/automation-test/jobSchedules/22222222-2222-2222-2222-222222222222"
    }
  }

  variables {
    automation_job_schedules = {
      standalone = {
        job_schedule_id = "11111111-1111-1111-1111-111111111111"
        runbook_key     = "cleanup"
        schedule_key    = "daily"
      }
    }
    automation_runbooks = {
      cleanup = {
        name                 = "cleanup-runbook"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/cleanup.ps1" }
        timeouts             = { create = "15m" }
        job_schedule = [{
          job_schedule_id = "22222222-2222-2222-2222-222222222222"
          schedule_key    = "hourly"
          run_on          = "inline-workers"
          parameters      = { environment = "migration" }
        }]
      }
    }
  }

  assert {
    condition = (
      azapi_resource.automation_account_job_schedules["standalone"].name == "11111111-1111-1111-1111-111111111111" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].name == "22222222-2222-2222-2222-222222222222" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].timeouts.create == "15m" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].body.properties.runOn == "inline-workers" &&
      azapi_resource.automation_account_job_schedules[jsonencode(["runbook", "cleanup", "hourly"])].body.properties.parameters.environment == "migration"
    )
    error_message = "Existing GUIDs must be retained, and inline settings and runbook timeouts must propagate."
  }
}

run "empty_job_schedules" {
  command = apply

  assert {
    condition     = length(azapi_resource.automation_account_job_schedules) == 0
    error_message = "Omitted standalone and inline jobs must create no job schedules."
  }
}

run "rejects_duplicate_association" {
  command = plan

  variables {
    automation_job_schedules = {
      duplicate = {
        runbook_key  = "cleanup"
        schedule_key = "daily"
      }
    }
    automation_runbooks = {
      cleanup = {
        name                 = "cleanup-runbook"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/cleanup.ps1" }
        job_schedule         = [{ schedule_key = "daily" }]
      }
    }
  }

  expect_failures = [var.automation_job_schedules]
}

run "rejects_unknown_reference" {
  command = plan

  variables {
    automation_job_schedules = {
      invalid = {
        runbook_key  = "missing"
        schedule_key = "daily"
      }
    }
  }

  expect_failures = [var.automation_job_schedules]
}

run "rejects_invalid_guid" {
  command = plan

  variables {
    automation_job_schedules = {
      invalid = {
        job_schedule_id = "not-a-guid"
        runbook_key     = "cleanup"
        schedule_key    = "daily"
      }
    }
  }

  expect_failures = [var.automation_job_schedules]
}

run "rejects_reused_import_guid" {
  command = plan

  variables {
    automation_job_schedules = {
      first = {
        job_schedule_id = "11111111-1111-1111-1111-111111111111"
        runbook_key     = "cleanup"
        schedule_key    = "daily"
      }
      second = {
        job_schedule_id = "11111111-1111-1111-1111-111111111111"
        runbook_key     = "cleanup"
        schedule_key    = "hourly"
      }
    }
  }

  expect_failures = [var.automation_job_schedules]
}

run "rejects_repeated_inline_schedule" {
  command = plan

  variables {
    automation_runbooks = {
      cleanup = {
        name                 = "cleanup-runbook"
        runbook_type         = "PowerShell"
        log_progress         = false
        log_verbose          = false
        publish_content_link = { uri = "https://example.com/cleanup.ps1" }
        job_schedule = [
          { schedule_key = "daily" },
          { schedule_key = "daily" },
        ]
      }
    }
  }

  expect_failures = [var.automation_runbooks]
}

run "rejects_uppercase_parameter_names" {
  command = plan

  variables {
    automation_job_schedules = {
      invalid = {
        runbook_key  = "cleanup"
        schedule_key = "daily"
        parameters   = { Environment = "test" }
      }
    }
  }

  expect_failures = [azapi_resource.automation_account_job_schedules]
}
