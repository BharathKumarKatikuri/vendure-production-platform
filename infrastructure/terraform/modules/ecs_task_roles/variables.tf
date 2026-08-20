variable "role_name" {
  description = "Name of the IAM role assumed by containers running inside the ECS task."
  type        = string
}

variable "amp_workspace_arn" {
  description = "ARN of the AMP workspace that the ECS task is allowed to write metrics to."
  type        = string
}

variable "tags" {
  description = "Tags applied to the ECS task IAM role."
  type        = map(string)
  default     = {}
}
