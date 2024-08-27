locals {
  env = var.env
  databricks_secret_scope_name = var.databricks_secret_scope_name
  acl_write_map = flatten([
    for id, val in local.databricks_secret_scope_name : [
      for name in val.WRITE :
      {
        index       = "${id}_${name}"
        name        = name
        scope_index = id
        isrequired  = val.permission_write_required
  }]])
}

#==============================================================
# Create secret scope
#==============================================================

resource "databricks_secret_scope" "dss" {
  for_each = local.databricks_secret_scope_name
  name = each.value.name
}

#==============================================================
# Provide permission to secret scope
#==============================================================
resource "databricks_secret_acl" "WRITE" {
  for_each = { for id in local.acl_write_map : id.index => id if id.isrequired == true }
  permission = "WRITE"
  scope = databricks_secret_scope.dss[each.value.scope_index].id
  principal = each.value.name  
}

#==============================================================
# add environment prefix to databricks secret
#===============================================================
resource "databricks_secret" "env_prefix" {
  key          = "env_prefix"
  string_value = local.env
  scope        = databricks_secret_scope.dss["ss1"].id
}
