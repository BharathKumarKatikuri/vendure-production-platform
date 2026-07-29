output "repository_name" {
  description = "Name of the Amazon ECR repository."

  value = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "Repository URL used for pushing and pulling Docker images."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the Amazon ECR repository."

  value = aws_ecr_repository.this.arn
}
