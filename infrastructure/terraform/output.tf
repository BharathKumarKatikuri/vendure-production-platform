output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "igw_id" {
  value = module.internet_gateway.igw_id
}


