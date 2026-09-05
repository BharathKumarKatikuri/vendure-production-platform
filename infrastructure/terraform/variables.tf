variable "aws_region" {
  type        = string
  description = "AWS region where infrastructure will be  deployed."
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr   = string
    az     = string
    public = bool
    name   = string
  }))
}


variable "igw_name" {
  type = string
}


variable "public_route_table_name" {
  description = "Name of the public route table"
  type        = string
}


variable "private_route_table_a_name" {
  description = "Name of private route table A"
  type        = string
}

variable "private_route_table_b_name" {
  description = "Name of private route table B"
  type        = string
}

variable "destination_cidr_block" {
  description = "Description CIDR block for the public route "
  type        = string
}


variable "elastic_ips" {
  description = "Name tag for the NAT Gateway Elastic IP"
  type = map(object({
    name = string
  }))
}


variable "nat_gateways" {
  description = "Configuration for NAT Gateways"

  type = map(object({
    eip_key    = string
    subnet_key = string
    name       = string
  }))
}


variable "security_groups" {
  description = "Configuration for Security Groups"
  type = map(object({
    name        = string
    description = string
  }))
}


variable "ecs_clusters" {
  type = map(object({
    name                       = string
    container_insights_enabled = bool
  }))
}



variable "ecs_task_definitions" {
  description = "Configuration for Vendure ECS task definition."

  type = map(object({
    family            = string
    container_name    = string
    container_image   = string
    container_port    = optional(number)
    container_command = optional(list(string), [])
    cpu               = number
    memory            = number
    metrics_port      = number
    log_group_key     = string
    environment       = optional(map(string), {})
    secrets           = optional(map(string), {})
  }))
}

variable "server_image_uri" {
  description = "Immutable ECR image URI for the Vendure API and Worker."
  type        = string
}

variable "storefront_image_uri" {
  description = "Immutable ECR image URI for the Vendure Storefront."
  type        = string
  default     = null
}


variable "ecs_task_execution_roles" {
  description = "ECS task execution roles used by each Vendure workload."

  type = map(object({
    role_name = string
  }))
}

variable "ecr_repositories" {
  description = "ECR repositories used by Vendure Workloads."

  type = map(object({
    repository_name = string
  }))
}

variable "ecr_scan_on_push" {
  description = "Enable automatic image scanning for the ECR repository."

  type    = bool
  default = true
}

variable "ecr_image_tag_mutability" {
  description = "Control whether image tags in the ECR repository are mutable."

  type    = string
  default = "MUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.ecr_image_tag_mutability
    )
    error_message = "Must be either MUTABLE OR IMMUTABLE."
  }
}

variable "ecr_encryption_type" {
  description = "Encryption type for the ECR repository."

  type    = string
  default = "AES256"

  validation {
    condition = contains(
      ["AES256", "KMS"],
      var.ecr_encryption_type
    )

    error_message = "Must be either AES256 or KMS."
  }
}

variable "s3_asset_bucket_name" {
  description = "Unique name for the Vendure production asset S3 bucket"
  type        = string

  validation {
    condition = (
      length(var.s3_asset_bucket_name) >= 3 &&
      length(var.s3_asset_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_asset_bucket_name))
    )

    error_message = "S3 asset bucket name must be between 3 and 63 characters and contain only lowercase letters, numbers, periods, and hyphens."
  }
}

variable "s3_asset_bucket_versioning" {
  description = "Whether versioning is enabled for the Vendure asset bucket"
  type        = bool
}

variable "s3_asset_bucket_encryption_type" {
  description = "Server-side encryption algorithm for the Vendure asset bucket"
  type        = string

  validation {
    condition = contains(
      ["AES256", "aws:kms"],
      var.s3_asset_bucket_encryption_type
    )

    error_message = "S3 asset bucket encryption type must be either AES256 or aws:kms."
  }
}

variable "s3_asset_public_access_block" {
  description = "Public access block configuration for the Vendure asset bucket"

  type = object({
    block_public_acls       = bool
    ignore_public_acls      = bool
    block_public_policy     = bool
    restrict_public_buckets = bool
  })
}

variable "s3_asset_force_destroy" {
  description = "Whether Terraform may delete the Vendure asset bucket when it contains objects"
  type        = bool
}


variable "cloudwatch_log_groups" {
  description = "CloudWatch log groups used by ECS containers."

  type = map(object({
    log_group_name    = string
    retention_in_days = number
  }))
}


variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
  default     = {}
}

variable "database_identifier" {
  description = "Identifier for the Vendure production RDS instance."
  type        = string
}

variable "database_name" {
  description = "Initial PostgreSQL database name for Vendure."
  type        = string
}

variable "master_username" {
  description = "Master username for the Vendure PostgreSQL instance."
  type        = string
}

variable "engine_version" {
  description = "Engine versiom for the Vendure PostgreSQL instance."
  type        = string
}

variable "parameter_group_family" {
  description = "parameter_group_family for the Vendure PostgreSQL instance."
  type        = string
}

variable "instance_class" {
  description = "instance class for the Vendure database"
  type        = string
}

variable "allocated_storage" {
  description = "allocating the storage for the PostgreSQL instance"
  type        = number
}

variable "max_allocated_storage" {
  description = "max_allocated_storage for the Vendure PostgreSQL instance."
  type        = number
}

variable "storage_type" {
  description = "storage type is used to select the type of storage for the PostgreSQL instance."
  type        = string
}

variable "database_port" {
  description = "Used to communicate with the instance."
  type        = number
}

variable "backup_retention_period" {
  description = "Used to store the backfiles."
  type        = number
}

variable "multi_az" {
  description = "Using multi-az for the avaliablity."
  type        = bool
}

variable "deletion_protection" {
  description = "Used for protection of data present in the RDS instance."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "skips the final snapshot in the Vendure PostgreSQL instance."
  type        = bool
}

variable "final_snapshot_identifier" {
  description = "final snapshot identifier used in the Vendure PostgreSQL instance."
  type        = string
  default     = null
}


variable "alb_name" {
  description = "Production Application Load Balancer name."
  type        = string
}

variable "alb_internal" {
  description = "Whether the production ALB is internal."
  type        = bool
}

variable "alb_load_balancer_type" {
  description = "Production load balancer type."
  type        = string
}


variable "target_groups" {
  description = "Configuration for ALB target groups."

  type = map(object({
    name              = string
    port              = number
    protocol          = string
    target_type       = string
    health_check_path = string
  }))
}

variable "alb_listener_port" {
  description = "Port on which the ALB listener accepts incoming traffic."
  type        = number
}

variable "alb_listener_protocol" {
  description = "Protocol used by the ALB listener."
  type        = string
}



variable "alb_listener_rule_priority" {
  description = "alb uses listener rule priority"
  type        = number
}

variable "alb_listener_rule_path_patterns" {
  description = "alb uses listener rule path patterns"
  type        = list(string)
}


variable "ecs_services" {
  description = "Configuration for Vendure ECS services."

  type = map(object({
    service_name     = string
    desired_count    = number
    assign_public_ip = bool
    container_name   = optional(string)
    container_port   = optional(number)
  }))
}


variable "amp_workspace_alias" {
  description = "Alias for the Amazon Managed service for Prometheus workspace."
  type        = string
}


variable "ecs_task_roles" {
  description = "IAM task roles used by each Vendure ECS workload."
  type = map(object({
    role_name = string
  }))
}


variable "adot_image" {
  description = "Pinned AWS Distro for OpenTelemetry collector image used by ECS sidecars."
  type        = string
}


variable "grafana_workspace_name" {
  description = "Name of the Amazon Managed Grafana workspace."
  type        = string
}

variable "grafana_authentication_providers" {
  description = "Authentication providers used by the Amazon Managed Grafana workspace."
  type        = set(string)
}

variable "grafana_account_access_type" {
  description = "AWS account access scope for the Amazon Managed Grafana workspace."
  type        = string
}

variable "grafana_permission_type" {
  description = "Permission model used by the Amazon Managed Grafana workspace."
  type        = string
}

variable "grafana_role_name" {
  description = "Name of the IAM role assumed by Amazon Managed Grafana."
  type        = string
}


variable "grafana_admin_user_ids" {
  description = "IAM Identity Center user IDs granted adminstrator access to the Grafana workspace."
  type        = set(string)
}



variable "app_secret_name" {
  description = "Name of the Secrets Manager secret used by the Vendure application."
  type        = string
}

variable "app_secret_recovery_window_in_days" {
  description = "Recovery window before permanent deletion of the Vendure application secret."
  type        = number

  validation {
    condition = (
      var.app_secret_recovery_window_in_days == 0 ||
      (
        var.app_secret_recovery_window_in_days >= 7 &&
        var.app_secret_recovery_window_in_days <= 30
      )
    )

    error_message = "app_secret_recovery_window_in_days must be 0 or between 7 and 30 days."
  }
}

variable "grafana_region" {
  description = "AWS region used for Amazon Managed Grafana."
  type        = string
}


variable "ses_email_identity" {
  description = "AWS SES used as the email sender identity"
  type        = string
}
