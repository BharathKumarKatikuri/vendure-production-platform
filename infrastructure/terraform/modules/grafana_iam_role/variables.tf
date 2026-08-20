variable "role_name" {
  description = "Name of the IAM role assumed by Amazon Managed Grafana."
  type        = string
}

variable "amp_workspace_arn" {
  description = "ARN of the AMP workspace that Grafana is allowed to query."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Grafana IAM role."
  type        = map(string)
  default     = {}
}
