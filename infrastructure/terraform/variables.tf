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
  type = map(object({
    family          = string
    container_name  = string
    container_image = string
    container_port  = number
    cpu             = number
    memory          = number
  }))
}


