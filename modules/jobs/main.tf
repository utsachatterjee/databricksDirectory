locals {}

#====================================================
# data source to retrieve latest spark version
#====================================================
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

#====================================================
# Create workflow/jobs
#====================================================
resource "databricks_job" "job" {
  for_each    = var.databricks_jobs
  name        = each.value.name
  description = each.value.description

  dynamic "job_cluster" {

    for_each = each.value.cluster_config != null ? each.value.cluster_config : {}

    content {
      job_cluster_key = job_cluster.value.clusterkey

      new_cluster {
        spark_version      = job_cluster.value.spark_version == null ? data.databricks_spark_version.latest_lts.id : job_cluster.value.spark_version
        node_type_id       = job_cluster.value.nodetype
        num_workers        = job_cluster.value.num_workers
        data_security_mode = job_cluster.value.data_security_mode
        instance_pool_id   = job_cluster.value.instance_pool_id
      }

    }

  }

  dynamic "task" {
    for_each = each.value.job_tasks
    content {
      task_key        = task.key
      job_cluster_key = task.value.task_type == "pipeline_task" ? null : task.value.task_type == "condition_task" ? null : each.value.cluster_config == null ? null : each.value.cluster_config["cl1"].clusterkey

      dynamic "condition_task" {
        for_each = task.value.task_type == "condition_task" ? [1] : []
        content {
          left  = task.value.task_specific_properties.left
          right = task.value.task_specific_properties.right
          op    = task.value.task_specific_properties.op
        }
      }
      run_if = task.value.run_if

      dynamic "notebook_task" {
        for_each = task.value.task_type == "notebook_task" ? [1] : []
        content {
          notebook_path   = task.value.task_specific_properties.notebook_path
          base_parameters = task.value.base_parameters
          warehouse_id    = can(task.value.task_specific_properties.warehouse_id) ? task.value.task_specific_properties.warehouse_id : null
        }
      }

      dynamic "depends_on" {
        for_each = task.value.depends_on_conditional == null ? [] : [1]
        content {
          task_key = lookup(task.value.depends_on_conditional, "task_key")
          outcome  = lookup(task.value.depends_on_conditional, "outcome")
        }
      }

      dynamic "depends_on" {
        for_each = task.value.depends_on == null ? [] : toset(task.value.depends_on)
        content {
          task_key = depends_on.value
        }
      }
    }
  }

  dynamic "schedule" {
    for_each = each.value.job_schedules != null ? each.value.job_schedules : []
    content {
      quartz_cron_expression = schedule.value.quartz_cron_expression
      timezone_id            = schedule.value.timezone_id
      pause_status           = schedule.value.pause_status
    }
  }
}

#==============================================================
# Provide permission
#===============================================================
resource "databricks_permissions" "job_usage" {
  for_each = var.databricks_jobs
  job_id   = databricks_job.job[each.key].id

  dynamic "access_control" {
    for_each = each.value.CAN_VIEW == null ? [] : each.value.CAN_VIEW
    content {
      group_name       = access_control.value
      permission_level = "CAN_VIEW"
    }
  }
  dynamic "access_control" {
    for_each = each.value.CAN_MANAGE_RUN == null ? [] : each.value.CAN_MANAGE_RUN
    content {
      group_name       = access_control.value
      permission_level = "CAN_MANAGE_RUN"
    }
  }
  dynamic "access_control" {
    for_each = each.value.CAN_MANAGE == null ? [] : each.value.CAN_MANAGE
    content {
      group_name       = access_control.value
      permission_level = "CAN_MANAGE"
    }
  }
}
