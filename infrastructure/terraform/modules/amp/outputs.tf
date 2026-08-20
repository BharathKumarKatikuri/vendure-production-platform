output "workspace_id" {
  description = "ID of the AMP workspace."
  value       = aws_prometheus_workspace.this.id
}

output "workspace_arn" {
  description = "ARN of the AMP workspace."
  value       = aws_prometheus_workspace.this.arn
}

output "prometheus_endpoint" {
  description = "Prometheus endpoint of the AMP workspace."
  value       = aws_prometheus_workspace.this.prometheus_endpoint
}
