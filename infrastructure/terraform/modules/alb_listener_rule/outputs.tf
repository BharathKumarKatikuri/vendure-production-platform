output "listener_rule_arn" {
  description = "ARN of the ALB listener rule."
  value       = aws_lb_listener_rule.this.arn
}

