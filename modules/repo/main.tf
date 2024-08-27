resource "databricks_git_credential" "bitbucket" {
  git_username          = "x-token-auth"
  git_provider          = "bitbucketCloud"
  personal_access_token = var.app_password
  force                 = true
}
#==============================================================
# Create databricks repo
#===============================================================
resource "databricks_repo" "db_repo" {
  for_each = var.databricks_workspace_repo
  url    = each.value.url
  git_provider = "bitbucketCloud"
  path   = each.value.path
  branch = each.value.branch
}

#==============================================================
# Provide permission
#===============================================================

resource "databricks_permissions" "repo_usage" {
    for_each = var.databricks_workspace_repo
    repo_id = databricks_repo.db_repo[each.key].id
  dynamic "access_control" {
    for_each = each.value.CAN_READ == null ? [] : each.value.CAN_READ
    content {
      group_name = access_control.value
      permission_level = "CAN_READ"
    }
  }
  dynamic "access_control" {
    for_each = each.value.CAN_RUN == null ? [] : each.value.CAN_RUN
    content {
      group_name = access_control.value
      permission_level = "CAN_RUN"
    }
  }
  dynamic "access_control" {
    for_each = each.value.CAN_EDIT == null ? [] : each.value.CAN_EDIT
    content {
      group_name = access_control.value
      permission_level = "CAN_EDIT"
    }
  }
  dynamic "access_control" {
    for_each = each.value.CAN_MANAGE == null ? [] : each.value.CAN_MANAGE
    content {
      group_name = access_control.value
      permission_level = "CAN_MANAGE"
    }
  }
}