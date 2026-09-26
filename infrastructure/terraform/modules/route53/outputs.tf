output "zone_id" {
  description = "Route 53 hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Route 53 name servers for domain delegation."
  value       = aws_route53_zone.this.name_servers
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the API domain."
  value       = aws_acm_certificate.api.arn
}

output "acm_certificate_domain" {
  description = "Domain covered by the ACM certificate."
  value       = aws_acm_certificate.api.domain_name
}
