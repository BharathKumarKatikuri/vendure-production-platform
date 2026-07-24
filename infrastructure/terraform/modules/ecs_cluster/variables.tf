variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_insights_enabled" {
  description = "whether container Insights is enabled for the ECS cluster"
  type        = bool
  default     = true
}
