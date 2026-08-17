resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids

  tags = var.tags
}

