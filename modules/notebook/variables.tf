variable "clean_room_name" {
  type        = string
  description = "the clean room notebook directory"
}

variable "notebooks" {
  type = map(object({
    notebook_name   = string
    notebook_source = string
  }))
  description = "the notebooks definition object"
}

variable "access_controls" {
  type = map(object({
    group_name       = string
    permission_level = string
  }))
  description = "the access controls definition object"

  validation {
    condition     = !contains([for k, v in var.access_controls : strcontains(v.permission_level, "CAN_MANAGE") || strcontains(v.permission_level, "CAN_EDIT")], true)
    error_message = "'CAN_MANAGE' or 'CAN_EDIT' is not allowd in the privileges."
  }
}

variable "databricks_workspace_url" {
  description = "databricks workspace url"
  type        = string
}

variable "env" {
  description = "The Env"
  type        = string
  nullable    = false
}
