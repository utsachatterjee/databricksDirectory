variable "databricks_workspace_url" {
  description = "databricks workspace url"
  type        = string
}

variable "databricks_secret_scope_name" {
  description = "databricks secretscope name"
  type        = map(object({
    name = string
    permission_read_required = optional(bool)
    permission_write_required = optional(bool)
    READ = optional(list(string))
    WRITE = optional(list(string))
  }))
}
variable "env" {
  description = "environment"
  type        = string
}
