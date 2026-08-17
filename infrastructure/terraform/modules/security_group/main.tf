resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.security_group_name
  }
}

