variable "role_name" {
  description = "Name of the IAM role used by ECS to pull images and publish logs."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ECS task execution IAM role."
  type        = map(string)
  default     = {}
}
