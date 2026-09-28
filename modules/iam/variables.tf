variable "name_prefix" {
  description = "Prefix applied to all IAM resource names."
  type        = string
}

variable "groups" {
  description = "IAM groups to create, keyed by short name, with AWS managed policy names to attach."
  type = map(object({
    managed_policy_names = list(string)
  }))
  default = {
    admins     = { managed_policy_names = ["AdministratorAccess"] }
    developers = { managed_policy_names = ["ReadOnlyAccess"] }
  }
}

variable "users" {
  description = "IAM users to create, keyed by user name, with the group short names they belong to."
  type = map(object({
    groups = list(string)
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for u in values(var.users) : [for g in u.groups : contains(keys(var.groups), g)]
    ]))
    error_message = "Every group listed for a user must exist in var.groups."
  }
}
