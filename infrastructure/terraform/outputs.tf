output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "igw_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = module.internet_gateway.igw_id
}


output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr["server"].repository_url
}


output "database_identifier" {
  description = "Identifier of the Vendure production RDS instance."
  value       = module.rds.database_identifier
}

output "database_arn" {
  description = "ARN of the Vendure production RDS instance."
  value       = module.rds.database_arn
}

output "database_endpoint" {
  description = "Endpoint of the Vendure production RDS instance."
  value       = module.rds.database_endpoint
}

output "database_address" {
  description = "Address of the Vendure production RDS instance."
  value       = module.rds.database_address
}

output "database_port" {
  description = "Databas port for the Vendure production RDS instance."
  value       = module.rds.database_port
}

output "database_name" {
  description = "Name for the RDS instance."
  value       = module.rds.database_name
}

output "db_subnet_group_name" {
  description = "subnet groups for the RDS instance."
  value       = module.rds.db_subnet_group_name
}

output "parameter_group_name" {
  description = "Parameter group for the RDS instance."
  value       = module.rds.parameter_group_name
}

output "master_user_secret_arn" {
  description = "master user secret arn used for authentication for RDS instance."
  value       = module.rds.master_user_secret_arn
}

output "database_allocated_storage" {
  description = "Allocated storage of the Vendure PostgreSQL instance in GiB."
  value       = module.rds.allocated_storage
}

output "database_max_allocated_storage" {
  description = "Maximum autoscaling storage limit of the Vendure PostgreSQL instance in GiB."
  value       = module.rds.max_allocated_storage
}

output "database_instance_class" {
  description = "Instance class of the Vendure PostgreSQL instance."
  value       = module.rds.instance_class
}

output "database_engine_version" {
  description = "PostgreSQL engine version used by Vendure."
  value       = module.rds.engine_version
}


output "alb_arn" {
  description = "ARN of the production Application Load Balancer."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the production Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the production Application Load Balancer."
  value       = module.alb.alb_zone_id
}


output "target_groups_arns" {
  description = "ARNs of the ALB target groups."

  value = {
    for key, target_groups in module.target_groups :
    key => target_groups.target_group_arn
  }
}


output "alb_listener_arn" {
  description = "ARN of the ALB listener."
  value       = module.alb_listener.listener_arn
}


output "alb_listener_rule_arn" {
  description = "ARN of the ALB listener rule."
  value       = module.alb_listener_rule.listener_rule_arn
}


output "ecs_service_names" {
  description = "Names of the Vendure ECS services."

  value = {
    for key, service in module.ecs_service :
    key => service.service_name
  }
}

output "ecs_service_ids" {
  description = "IDs of the Vendure ECS services."

  value = {
    for key, service in module.ecs_service :
    key => service.service_id
  }
}


output "amp_workspace_id" {
  description = "ID of the Amazon Managed Service for the Prometheus workspace."
  value       = module.amp.workspace_id
}

output "amp_workspace_arn" {
  description = "ARN of the Amazon Managed Service for Prometheus workspace."
  value       = module.amp.workspace_arn
}

output "amp_prometheus_endpoint" {
  description = "Prometheus endpoint of the AMP workspace."
  value       = module.amp.prometheus_endpoint
}



output "grafana_workspace_id" {
  description = "ID of the Amazon Managed Service for the Grafana workspace"
  value       = module.grafana.workspace_id
}

output "grafana_workspace_arn" {
  description = "ARN of the Amazon Managed Service for the Grafana workspace."
  value       = module.grafana.workspace_arn
}

output "grafana_workspace_endpoint" {
  description = "Grafana endpoint of the workspace."
  value       = module.grafana.workspace_endpoint
}
