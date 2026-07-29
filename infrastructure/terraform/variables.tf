variable "aws_region" {
  type        = string
  description = "AWS region where infrastructure will be  deployed."
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr   = string
    az     = string
    public = bool
    name   = string
  }))
}


variable "igw_name" {
  type = string
}


variable "public_route_table_name" {
  description = "Name of the public route table"
  type        = string
}


variable "private_route_table_a_name" {
  description = "Name of private route table A"
  type        = string
}

variable "private_route_table_b_name" {
  description = "Name of private route table B"
  type        = string
}

variable "destination_cidr_block" {
  description = "Description CIDR block for the public route "
  type        = string
}


variable "elastic_ips" {
  description = "Name tag for the NAT Gateway Elastic IP"
  type = map(object({
    name = string
  }))
}


variable "nat_gateways" {
  description = "Configuration for NAT Gateways"

  type = map(object({
    eip_key    = string
    subnet_key = string
    name       = string
  }))
}


variable "security_groups" {
  description = "Configuration for Security Groups"
  type = map(object({
    name        = string
    description = string
    ingress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))

    egress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))

  }))
}


variable "ecs_clusters" {
  type = map(object({
    name                       = string
    container_insights_enabled = bool
  }))
}



variable "ecs_task_definitions" {
  description = "Configuration for Vendure ECS task definition."

  type = map(object({
    family            = string
    container_name    = string
    container_image   = string
    container_port    = optional(list(number), [])
    container_command = optional(list(string), [])
    cpu               = number
    memory            = number
    log_group_key     = string
    environment       = optional(map(string), {})
    secrets           = optional(map(string), {})
  }))
}

variable "ecs_task_execution_role_name" {
  description = "Name of the IAM role used by ECS to pull images from ECR and publish container logs."
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository."

  type = string
}

variable "ecr_scan_on_push" {
  description = "Enable automatic image scanning for the ECR repository."

  type    = bool
  default = true
}

variable "ecr_image_tag_mutability" {
  description = "Control whether image tags in the ECR repository are mutable."

  type    = string
  default = "MUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.ecr_image_tag_mutability
    )
    error_message = "Must be either MUTABLE OR IMMUTABLE."
  }
}

variable "ecr_encryption_type" {
  description = "Encryption type for the ECR repository."

  type    = string
  default = "AES256"

  validation {
    condition = contains(
      ["AES256", "KMS"],
      var.ecr_encryption_type
    )

    error_message = "Must be either AES256 or KMS."
  }
}


variable "cloudwatch_log_groups" {
  description = "CloudWatch log groups used by ECS containers."

  type = map(object({
    log_group_name    = string
    retention_in_days = number
  }))
}


variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
  default     = {}
}
