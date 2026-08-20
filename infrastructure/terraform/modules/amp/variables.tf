variable "workspace_alias" {
  description = "Alias for the Amazon Managed Service for Prometheus workspace."
  type        = string
}

variable "tags" {
  description = "Tags applied to the AMP workspace."
  type        = map(string)
}
