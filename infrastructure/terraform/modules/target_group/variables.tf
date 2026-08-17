variable "target_group_name" {
  description = "Name of the ALB target group."
  type        = string
}

variable "target_group_port" {
  description = "Port on which the target group forwards traffic"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol used by the target group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created."
  type        = string
}

variable "target_group_type" {
  description = "Type of target group"
  type        = string
}

variable "target_group_health_check_path" {
  description = "Checks the path health in target group."
  type        = string
}

variable "tags" {
  description = "Common tags for the target group."
  type        = map(string)
  default     = {}
}




