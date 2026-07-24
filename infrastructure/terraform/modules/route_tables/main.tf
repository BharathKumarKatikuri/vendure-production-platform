resource "aws_route_table" "this" {
  vpc_id = var.vpc_id


  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = var.destination_cidr_block

  gateway_id     = var.igw_id
  nat_gateway_id = var.nat_gateway_id
}

resource "aws_route_table_association" "this" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}



