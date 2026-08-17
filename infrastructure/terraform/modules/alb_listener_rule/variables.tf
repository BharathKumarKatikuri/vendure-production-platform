variable "listener_arn" {
  description = "alb listener rule uses alb listener arn"
  type        = string
}

variable "priority" {
  description = "alb listener rule uses priority"
  type        = number
}

variable "path_patterns" {
  description = "alb listener rule uses path pattern."
  type        = list(string)
}

variable "target_group_arn" {
  description = "alb listener uses target group arn"
  type        = string
}


