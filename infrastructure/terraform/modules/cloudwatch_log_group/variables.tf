variable "log_group_name" {
  description = "Name of the CloudWatch log group used by an ECS container."
  type        = string
}

variable "retention_in_days" {
  description = "Number of days CloudWatch retains container logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the CloudWatch log group."
  type        = map(string)
  default     = {}
}
