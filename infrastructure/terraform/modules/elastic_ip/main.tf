resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = var.elastic_ip_name
  }
}
