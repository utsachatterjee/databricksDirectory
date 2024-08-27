output "jobs" {
  value = tomap({ for k, s in databricks_job.job : k => s.id })
}