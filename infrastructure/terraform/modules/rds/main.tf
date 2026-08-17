resource "aws_db_instance" "this" {
  identifier           = var.database_identifier
  db_name              = var.database_name
  engine               = "postgres"
  engine_version       = var.engine_version
  username             = var.master_username
  parameter_group_name = aws_db_parameter_group.this.name

  manage_master_user_password = true

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  port                   = var.database_port
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = true

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  tags = merge(
    var.common_tags,
    {
      Name = var.database_identifier
    }
  )

  lifecycle {
    precondition {
      condition     = var.max_allocated_storage >= var.allocated_storage
      error_message = "Maximum allocated storage must be greater than or equal to allocated storage."
    }

    precondition {
      condition = (
        trimprefix(var.parameter_group_family, "postgres") ==
        split(".", var.engine_version)[0]
      )
      error_message = "Parameter group family must match the PostgreSQL engine major version."
    }

    precondition {
      condition = (
        var.skip_final_snapshot ||
        try(trimspace(var.final_snapshot_identifier), "") != ""

      )

      error_message = "Final snapshot identifier must be provided when skip_final_snapshot is false."
    }
  }
}
