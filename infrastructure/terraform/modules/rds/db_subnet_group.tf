resource "aws_db_subnet_group" "this" {
  name        = "${var.database_identifier}-subnet-group"
  description = "Private subnet group used by the RDS PostgreSQL instance."
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.database_identifier}-subnet-group"
    }
  )
}
