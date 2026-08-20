variable "workspace_name" {
  description = "Workspace Name for the grafana"
  type        = string
}

variable "authentication_providers" {
  description = "Authentication providers used to access the Amazon managed Grafana"
  type        = set(string)
}

variable "tags" {
  description = "Common tags for to access Grafana"
  type        = map(string)
  default     = {}
}


variable "account_access_type" {
  description = "AWS account access scope for the Grafana workspace."
  type        = string
}

variable "permission_type" {
  description = "Permission model used by the Amazon Managed Grafana workspace."
  type        = string
}


variable "role_arn" {
  description = "IAM role ARN used by Amazon Managed Grafana to access AWS data sources."
  type        = string
}

variable "admin_user_ids" {
  description = "IAM Identity Center user IDs granted administrator access to the Grafana workspace."
  type        = set(string)
}
