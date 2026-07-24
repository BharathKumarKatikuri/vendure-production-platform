variable "vpc_id" {
  description = "VPC ID where the route table will be created"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID for a route table"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "subnet IDs to associate with the route table"
  type        = set(string)
}

variable "destination_cidr_block" {
  description = "Destination CIDR block for the default route"
  type        = string
}

variable "route_table_name" {
  description = "Name tag for the route table"
  type        = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for a private route table"
  type        = string
  default     = null
}
