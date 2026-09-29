variable "load_balancer_arn" {
  description = "Uses load balancer arn to liesten alb."
  type        = string
}

variable "listener_port" {
  description = "ALB listens to this port."
  type        = number
}

variable "listener_protocol" {
  description = "protocols used by the ALB listener."
  type        = string
}

variable "default_target_group_arn" {
  description = "ARN of the target group used by the listener's default forward action."
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN used by an HTTPS listener."
  type        = string
  default     = null
}

variable "redirect_to_https" {
  description = "Whether the HTTP listener redirects requests to HTTPS."
  type        = bool
  default     = false
}
