variable "family" {
  description = "Name of the ECS task definition family"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Immutable ECR image URI used by the container."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = null
}

variable "container_command" {
  description = "command used to start the container."
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "cpu units for the task"
  type        = number
}

variable "memory" {
  description = "memory for the task"
  type        = number
}

variable "execution_role_arn" {
  description = "IAM role ARN used by ECS to pu;; images and publish logs."
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "IAM role ARN assumed by the running application container."
  type        = string
  default     = null
}

variable "log_group_name" {
  description = "CloudWatch log group receiving container logs."
  type        = string
}

variable "aws_region" {
  description = "AWS region containing the ECS resources."
  type        = string
}

variable "environment" {
  description = "Non-sensitive environments variables passed to the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Sensitive environment variables mapped to Secrets Manager or Parameter Store ARNs."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to the ECS task definition."
  type        = map(string)
  default     = {}
}

variable "sidecar_container" {
  description = "Optional sidecar container running alongside the primary application"

  type = object({
    name           = string
    image          = string
    essential      = bool
    command        = list(string)
    environment    = map(string)
    log_group_name = string
  })

  default = null
}
