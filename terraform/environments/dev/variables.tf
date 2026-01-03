variable "pr_number" {
  description = "Pull request number"
  type        = string
}

variable "environment_name" {
  description = "Environment name (e.g., pr-123)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "previewdb"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "previewuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
