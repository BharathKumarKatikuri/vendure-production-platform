output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "igw_id" {
  value = module.internet_gateway.igw_id
}


output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}


