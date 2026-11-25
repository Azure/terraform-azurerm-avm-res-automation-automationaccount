locals {
  automation_runbook_job_schedules = {
    for job in flatten([
      for runbook_key, runbook in var.automation_runbooks : [
        for job in runbook.job_schedule == null ? [] : runbook.job_schedule : merge(job, {
          key         = jsonencode(["runbook", runbook_key, job.schedule_key])
          runbook_key = runbook_key
        })
      ]
    ]) : job.key => job
  }
  automation_job_schedules = merge(
    var.automation_job_schedules,
    local.automation_runbook_job_schedules,
  )
}
