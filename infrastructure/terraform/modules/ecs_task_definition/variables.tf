variable "family" {
  description = "Name of the ECS task definition family"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Image of the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "cpu" {
  description = "cpu units for the task"
  type        = number
}

variable "memory" {
  description = "memory for the task"
  type        = number
}


