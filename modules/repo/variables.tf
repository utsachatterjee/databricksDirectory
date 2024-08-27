variable "databricks_workspace_url" {
  description = "databricks workspace url"
  type        = string
}

variable "git_username" {
  description = "username for git credential"
  type        = string
  default = ""
  nullable = true
}

variable "repo_provider" {
  description = "git provider of remote repo containing the notebook script file"
  type        = string
  default     = ""
  nullable    = true
}

variable "app_password" {
  description = "app password for connecting to bitbucket"
  type        = string
  default     = ""
  nullable    = true
}

variable "databricks_workspace_repo" {
  type = map(object({
    url  = string
    path = string
    branch = string
    CAN_MANAGE = optional(list(string))
    CAN_READ = optional(list(string))
    CAN_RUN = optional(list(string))
    CAN_EDIT = optional(list(string))
  }))
  description = "git repos to be cloned in databricks"
}
