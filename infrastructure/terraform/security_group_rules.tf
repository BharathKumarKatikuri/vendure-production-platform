resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = module.security_group["alb"].security_group_id

  description = "Allow HTTP traffic from the internet."
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = module.security_group["alb"].security_group_id

  description = "Allow HTTPS traffic from the internet."
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_api_from_alb" {
  security_group_id = module.security_group["ecs_api"].security_group_id

  description                  = "Allow ALB traffic to the Vendure API."
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = module.security_group["alb"].security_group_id
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_api" {
  security_group_id = module.security_group["alb"].security_group_id

  description                  = "Allow ALB traffic to the Vendure API."
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = module.security_group["ecs_api"].security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_storefront_from_alb" {
  security_group_id = module.security_group["ecs_storefront"].security_group_id

  description                  = "Allow ALB traffic to the Vendure storefront."
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  referenced_security_group_id = module.security_group["alb"].security_group_id
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_storefront" {
  security_group_id = module.security_group["alb"].security_group_id

  description                  = "Allow ALB traffic to the Vendure storefront."
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  referenced_security_group_id = module.security_group["ecs_storefront"].security_group_id
}


resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_api" {
  security_group_id = module.security_group["rds"].security_group_id

  description                  = "Allow PostgreSQL traffic from Vendure ECS tasks."
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = module.security_group["ecs_api"].security_group_id
}


resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_worker" {
  security_group_id = module.security_group["rds"].security_group_id

  description                  = "Allow PostgreSQL traffic from Vendure worker ECS tasks."
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = module.security_group["ecs_worker"].security_group_id
}


resource "aws_vpc_security_group_egress_rule" "ecs_api_outbound" {
  security_group_id = module.security_group["ecs_api"].security_group_id

  description = "Allowed outbound traffic from Vendure ECS tasks."
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ecs_storefront_outbound" {
  security_group_id = module.security_group["ecs_storefront"].security_group_id

  description = "Allow outbound traffic from Vendure storefront ECS tasks."
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ecs_worker_outbound" {
  security_group_id = module.security_group["ecs_worker"].security_group_id

  description = "Allow outbound traffic from Vendure worker ECS tasks."
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

