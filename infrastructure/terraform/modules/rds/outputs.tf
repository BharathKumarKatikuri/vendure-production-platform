output "database_identifier" {
  description = "Useful for monitoring, IAM, alarms and verification."
  value       = aws_db_instance.this.identifier
}

output "database_arn" {
  description = "Useful for security validation and monitoring the instance."
  value       = aws_db_instance.this.arn
}

output "database_endpoint" {
  description = "Vendure API and Worker use this to connect to PostgreSQL."
  value       = aws_db_instance.this.endpoint
}

output "database_address" {
  description = "Using this address APIs and Worker connect to PostgreSQL."
  value       = aws_db_instance.this.address
}

output "database_port" {
  description = "Vendure API and Worker uses this Port to connect PostgreSQL."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "tells Vendure which PostgreSQL database to use."
  value       = aws_db_instance.this.db_name
}

output "db_subnet_group_name" {
  description = "PostgreSQL works on db subnet groups."
  value       = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Using parameter group for verification and future references."
  value       = aws_db_parameter_group.this.name
}

output "master_username" {
  description = "Uses the Unique name for the instance."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "master_user_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the RDS master-user credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "allocated_storage" {
  description = "Allocated storage of the RDS instance in GiB."
  value       = aws_db_instance.this.allocated_storage
}

output "max_allocated_storage" {
  description = "Maximum autoscaling storage limit of the RDS instance in GiB."
  value       = aws_db_instance.this.max_allocated_storage
}

output "instance_class" {
  description = "Instance class of the RDS instance."
  value       = aws_db_instance.this.instance_class
}

output "engine_version" {
  description = "PostgreSQL engine version used by the RDS instance."
  value       = aws_db_instance.this.engine_version
}
