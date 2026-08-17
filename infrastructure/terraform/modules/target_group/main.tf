resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_group_type

  health_check {
    path = var.target_group_health_check_path
  }

  tags = var.tags
}

