output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ID of the ECS service."
  value       = aws_ecs_service.this.id
}


