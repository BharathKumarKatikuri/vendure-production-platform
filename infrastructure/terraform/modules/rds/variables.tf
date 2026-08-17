variable "database_identifier" {
  description = "Unique identifier used for the RDS DB instance."
  type        = string

  validation {
    condition = (
      length(var.database_identifier) >= 1 &&
      length(var.database_identifier) <= 63 &&
      can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.database_identifier)) &&
      !strcontains(var.database_identifier, "--")
    )

    error_message = "Database identifier must be --63 characters, start with a lowercase letters, numbers, and hyphens, and must not end with a hyphen or contain consecutive hyphens."
  }
}

variable "database_name" {
  description = "Name for the initial PostgreSQL database created inside the RDS instance."
  type        = string

  validation {
    condition = can(
      regex(
        "^[A-Za-z][A-Za-z0-9]{0,62}$",
        var.database_name
      )
    )
    error_message = "Database name must be 1-63 characters, start with a letters, and contain only letters and numbers."
  }
}

variable "master_username" {
  description = "Master username used to administer the RDS PostgreSQL instance."
  type        = string

  validation {
    condition = (
      can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.master_username)) &&
      lower(var.master_username) != "postgres"
    )

    error_message = "Master username must be 1-62 characters, start with a letter, contain only letters, numbers, and underscores, and must not be postgres"
  }
}

variable "engine_version" {
  description = "PostgreSQL engine version used by the RDS instance."

  type = string

  validation {
    condition = can(
      regex(
        "^[0-9]+(\\.[0-9]+)*$",
        var.engine_version
      )
    )
    error_message = "Engine version must contain only numeric version components, such as 16 or 16.3."
  }
}


variable "parameter_group_family" {
  description = "PostgreSQL parameter group family compatible with the selected engine major version."
  type        = string

  validation {
    condition = can(
      regex(
        "^postgres[0-9]+$",
        var.parameter_group_family
      )
    )
    error_message = "Parameter group family must use the format postgres followed by the major version, such as postgres16."
  }
}

variable "instance_class" {
  description = "The RDS instance class that determines the CPU and memory capacity"
  type        = string

  validation {
    condition = can(
      regex(
        "^db\\.[a-z0-9-]+\\.[a-z0-9-]+$",
        var.instance_class
      )
    )
    error_message = "Instance class must use a valid RDS format, such as db.t4g.micro."
  }
}

variable "allocated_storage" {
  description = "Initial storage capacity allocated to the RDS instance in GiB."
  type        = number

  validation {
    condition = (
      var.allocated_storage >= 20 &&
      floor(var.allocated_storage) == var.allocated_storage
    )

    error_message = "Allocated storage must be a whole number of at least 20 GiB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum storage capacity in GiB that RDS storage autoscaling can allocate."
  type        = number

  validation {
    condition = (
      var.max_allocated_storage > 20 &&
      floor(var.max_allocated_storage) == var.max_allocated_storage
    )

    error_message = "Maximum allocated storage must be a whole number of at least 20 GiB."
  }
}

variable "storage_type" {
  description = "Storage type used by the RDS instance."
  type        = string

  validation {
    condition     = var.storage_type == "gp3"
    error_message = "Storage type must be gp3 for the Vendure RDS instance."
  }
}


variable "database_port" {
  description = "Network port used by the PostgreSQL RDS instance.vendure-production-platform."
  type        = number

  validation {
    condition     = var.database_port >= 1 && var.database_port <= 65535
    error_message = "Database port must be between 1 and 65535."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the RDS instance."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) >= 1
    error_message = "At least one security group ID must be provided for the RDS instance."
  }
}

variable "backup_retention_period" {
  description = "Number of days that RDS retains automated database backups."
  type        = number

  validation {
    condition = (
      var.backup_retention_period >= 1 &&
      var.backup_retention_period <= 35
    )
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "multi_az" {
  description = "Whether the RDS instance should deploy a standby instance in another Availability Zone."
  type        = bool
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the RDS instance."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether RDS should skip creating a final snapshot when the instance is deleted."
  type        = bool
}

variable "final_snapshot_identifier" {
  description = "Identifier assigned to the final RDS snapshot when the instance is deleted."
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to the RDS resources."
  type        = map(string)
  default     = {}
}


