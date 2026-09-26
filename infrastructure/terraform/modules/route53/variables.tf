variable "domain_name" {
  description = "Root domain name for the Route 53 hosted zone."
  type        = string
}

variable "api_domain_name" {
  description = "Domain name used for the production API."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  type        = string
}

variable "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  type        = string
}
