variable "allocation_id" {
  description = "Allocation ID for the Elastci IP used by the NAT Gateway"
  type        = string
}

variable "subnet_id" {
  description = "ID of the public subnet where the NAT Gateway will be created"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

