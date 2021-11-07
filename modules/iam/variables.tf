
variable "project" {
  type        = string
  description = "Project ID."
}

variable "service_account" {
  type        = list(string)
  description = "List of Service account."
}

variable "group_name" {
  type        = list(string)
  description = "List of groups."
  default     = []
}

variable "create_service_account" {
  type        = bool
  description = "Boolean to check if we want to create a service accounts in the list."
  default     = false
}

variable "mode_authoritative" {
  type        = bool
  description = "Boolean to check if we want to add the permission as Authoritative."
  default     = false
}

variable "access" {
  type        = list(any)
  description = "Access list of permission which needs to be assigned to the service account."
}

variable "project_iam" {
  type        = list(any)
  description = "List of products the services account will have min permission at project level."
  default     = []
}

variable "access_conditions" {
  type        = map(any)
  description = "Access conditions for the service account"
  default     = {}
}