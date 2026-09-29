resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  certificate_arn = var.certificate_arn

  default_action {
    type = var.redirect_to_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.redirect_to_https ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.redirect_to_https ? null : var.default_target_group_arn
  }
}
