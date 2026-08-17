variable "alb_name" {
  description = "Production Application Load Balancer name."
  type        = string
}

variable "internal" {
  description = "Whether the production ALB is internal."
  type        = bool
}

variable "load_balancer_type" {
  description = "Production load balancer type."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the ALB."
  type        = list(string)
}

variable "subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied for the ALB"
  type        = map(string)
  default     = {}
}

