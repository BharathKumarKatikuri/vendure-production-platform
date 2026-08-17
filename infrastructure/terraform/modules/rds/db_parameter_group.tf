resource "aws_db_parameter_group" "this" {
  name        = "${var.database_identifier}-parameter-group"
  description = "Custom PostgreSQL parameter group used by the Vendure RDS instance."
  family      = var.parameter_group_family

  tags = merge(
    var.common_tags,
    {
      Name = "${var.database_identifier}-parameter-group"
    }
  )
}
