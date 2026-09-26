resource "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_acm_certificate" "api" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_certificate_validation" {
  count = 1

  zone_id = aws_route53_zone.this.zone_id
  name    = tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_type
  ttl     = 300
  records = [
    tolist(aws_acm_certificate.api.domain_validation_options)[0].resource_record_value
  ]

  allow_overwrite = true
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
