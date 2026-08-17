variable "service_name" {
  description = "To create a ecs service we need a name"
  type        = string
}

variable "cluster_arn" {
  description = "ecs services use cluster_arn"
  type        = string
}

variable "task_definition_arn" {
  description = "ecs services uses task definition to run the service."
  type        = string
}

variable "desired_count" {
  description = "ecs services have desired count."
  type        = number
}

variable "subnet_ids" {
  description = "ecs services uses subnet ids."
  type        = list(string)
}

variable "security_group_ids" {
  description = "ecs services uses security group ids."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "ecs services uses public ip."
  type        = bool
}

variable "container_name" {
  description = "ecs services uses container name."
  type        = string
  default     = null
}

variable "container_port" {
  description = "ecs services uses container port."
  type        = number
  default     = null
}

variable "target_group_arn" {
  description = "ecs services uses target group port."
  type        = string
  default     = null
}

