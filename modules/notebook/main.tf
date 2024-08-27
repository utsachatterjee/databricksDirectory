locals {
  default_tags = {
    purpose = "resource group"
  }
}

resource "databricks_directory" "dd" {
  path = "/clean_room/${var.clean_room_name}"
}

resource "databricks_notebook" "dn" {
  for_each = var.notebooks
  path     = "/clean_room/${var.clean_room_name}/${each.value.notebook_name}"
  source   = each.value.notebook_source
}

resource "databricks_permissions" "dpdd" {
  directory_path = "/clean_room/${var.clean_room_name}"
  depends_on     = [databricks_directory.dd]
  dynamic "access_control" {
    for_each = var.access_controls
    content {
      group_name       = strcontains(lower(access_control.value.group_name), "deployment") || strcontains(lower(access_control.value.group_name), "dbx") ? "${access_control.value.group_name}_${var.env}" : access_control.value.group_name
      permission_level = access_control.value.permission_level
    }
  }
}
