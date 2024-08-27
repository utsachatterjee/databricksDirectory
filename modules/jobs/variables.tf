variable "databricks_workspace_url" {
  description = "databricks workspace url"
  type        = string
}

variable "databricks_jobs" {
  description = "databricks job name"
  type = map(object({
    name        = string
    description = string
    cluster_config = optional(map(object({
      createCluster      = optional(bool)
      clusterkey         = string
      nodetype           = string
      spark_version      = optional(string)
      num_workers        = optional(number)
      data_security_mode = optional(string)
      instance_pool_id   = optional(string)
    })))
    job_tasks = map(object({
      task_type                = string
      run_if                   = optional(string)
      job_cluster_key          = optional(string)
      depends_on               = optional(list(string))
      depends_on_conditional   = optional(map(any))
      task_specific_properties = optional(map(any))
      base_parameters          = optional(map(any))
    }))
    job_schedules = optional(list(object({
      quartz_cron_expression = string
      timezone_id            = string
      pause_status           = optional(string)
    })))
    CAN_VIEW       = optional(list(string))
    CAN_MANAGE     = optional(list(string))
    CAN_MANAGE_RUN = optional(list(string))
  }))
}
