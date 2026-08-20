output "role_arn" {
  description = "ARN of the ECS task IAM role."
  value       = aws_iam_role.this.arn
}
