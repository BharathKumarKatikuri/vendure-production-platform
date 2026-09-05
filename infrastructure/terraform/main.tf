module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "subnets" {
  for_each = var.subnets

  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = each.value.cidr
  az                      = each.value.az
  map_public_ip_on_launch = each.value.public
  subnet_name             = each.value.name
}

module "internet_gateway" {
  source   = "./modules/internet_gateway"
  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
}


module "public_route_table" {
  source = "./modules/route_tables"


  vpc_id                 = module.vpc.vpc_id
  route_table_name       = var.public_route_table_name
  destination_cidr_block = var.destination_cidr_block
  igw_id                 = module.internet_gateway.igw_id
  nat_gateway_id         = null

  subnet_ids = {
    public_a = module.subnets["public_a"].subnet_id
    public_b = module.subnets["public_b"].subnet_id
  }
}
module "private_route_table_a" {
  source                 = "./modules/route_tables"
  vpc_id                 = module.vpc.vpc_id
  route_table_name       = var.private_route_table_a_name
  destination_cidr_block = var.destination_cidr_block

  igw_id         = null
  nat_gateway_id = module.nat_gateway["nat_a"].nat_gateway_id

  subnet_ids = {
    private_a = module.subnets["private_a"].subnet_id
  }
}

module "private_route_table_b" {
  source = "./modules/route_tables"

  vpc_id                 = module.vpc.vpc_id
  route_table_name       = var.private_route_table_b_name
  destination_cidr_block = var.destination_cidr_block

  igw_id         = null
  nat_gateway_id = module.nat_gateway["nat_b"].nat_gateway_id

  subnet_ids = {
    private_b = module.subnets["private_b"].subnet_id
  }
}



module "elastic_ip" {
  for_each = var.elastic_ips

  source = "./modules/elastic_ip"

  elastic_ip_name = each.value.name
}


module "nat_gateway" {
  for_each = var.nat_gateways

  source = "./modules/nat_gateway"

  allocation_id = module.elastic_ip[each.value.eip_key].allocation_id
  subnet_id     = module.subnets[each.value.subnet_key].subnet_id

  nat_gateway_name = each.value.name
}



module "security_group" {
  for_each = var.security_groups

  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = each.value.name
  description         = each.value.description
}


module "ecs_cluster" {
  for_each = var.ecs_clusters

  source = "./modules/ecs_cluster"

  cluster_name               = each.value.name
  container_insights_enabled = each.value.container_insights_enabled
  tags                       = var.common_tags
}

module "ecs_task_definition" {
  for_each = var.ecs_task_definitions

  source = "./modules/ecs_task_definition"

  family         = each.value.family
  container_name = each.value.container_name
  container_image = contains(["api", "worker"], each.key) ? var.server_image_uri : (
    each.key == "storefront" && var.storefront_image_uri != null
    ? var.storefront_image_uri
    : each.value.container_image
  )
  container_port    = each.value.container_port
  container_command = each.value.container_command
  cpu               = each.value.cpu
  memory            = each.value.memory

  execution_role_arn = module.ecs_task_execution_role[each.key].role_arn
  task_role_arn      = module.ecs_task_role[each.key].role_arn

  log_group_name = module.cloudwatch_log_group[each.value.log_group_key].log_group_name
  aws_region     = var.aws_region

  environment = merge(
    each.value.environment,
    contains(["api", "worker"], each.key) ? {
      DB_HOST              = module.rds.database_address
      DB_PORT              = tostring(module.rds.database_port)
      DB_NAME              = module.rds.database_name
      S3_ASSET_BUCKET_NAME = module.s3_asset_bucket.bucket_id
      AWS_REGION           = var.aws_region

      EMAIL_FROM_ADDRESS = module.ses.email_identity
      STOREFRONT_URL     = "http://${module.alb.alb_dns_name}"
    } : {},

    each.key == "storefront" ? {
      VENDURE_SHOP_API_URL = "http://${module.alb.alb_dns_name}/shop-api"
    } : {}

  )

  secrets = merge(
    each.value.secrets,

    contains(["api", "worker"], each.key) ? {
      DB_USERNAME = "${module.rds.master_user_secret_arn}:username::"
      DB_PASSWORD = "${module.rds.master_user_secret_arn}:password::"
    } : {},

    each.key == "api" ? {
      SUPERADMIN_USERNAME = "${module.app_secret.secret_arn}:SUPERADMIN_USERNAME::"
      SUPERADMIN_PASSWORD = "${module.app_secret.secret_arn}:SUPERADMIN_PASSWORD::"
      COOKIE_SECRET       = "${module.app_secret.secret_arn}:COOKIE_SECRET::"
    } : {}
  )


  tags = var.common_tags

  sidecar_container = {
    name      = "adot-collector"
    image     = var.adot_image
    essential = false
    command = [
      "--config=env:AOT_CONFIG_CONTENT"
    ]

    environment = {
      AOT_CONFIG_CONTENT = templatefile(
        "${path.module}/templates/adot-prometheus.yaml.tftpl",
        {
          aws_region = var.aws_region

          job_name = each.value.container_name

          metrics_port = each.value.metrics_port

          amp_remote_write_endpoint = "${trimsuffix(module.amp.prometheus_endpoint, "/")}/api/v1/remote_write"

        }
      )
    }

    log_group_name = module.cloudwatch_log_group["adot"].log_group_name
  }
}


moved {
  from = module.ecs_task_execution_role
  to   = module.ecs_task_execution_role["api"]
}


module "ecs_task_execution_role" {
  for_each = var.ecs_task_execution_roles

  source = "./modules/ecs_task_execution_role"

  role_name = each.value.role_name

  secret_arns = each.key == "api" ? [
    module.rds.master_user_secret_arn,
    module.app_secret.secret_arn
    ] : each.key == "worker" ? [
    module.rds.master_user_secret_arn

  ] : []

  tags = var.common_tags
}

module "cloudwatch_log_group" {
  for_each = var.cloudwatch_log_groups

  source = "./modules/cloudwatch_log_group"

  log_group_name    = each.value.log_group_name
  retention_in_days = each.value.retention_in_days
  tags              = var.common_tags
}

module "ecr" {
  for_each = var.ecr_repositories

  source = "./modules/ecr"

  repository_name      = each.value.repository_name
  scan_on_push         = var.ecr_scan_on_push
  image_tag_mutability = var.ecr_image_tag_mutability
  encryption_type      = var.ecr_encryption_type

  tags = merge(
    var.common_tags,
    {
      Name = each.value.repository_name
    }
  )
}

moved {
  from = module.ecr
  to   = module.ecr["server"]
}


module "s3_asset_bucket" {
  source = "./modules/s3_bucket"

  s3_bucket_name            = var.s3_asset_bucket_name
  s3_bucket_versioning      = var.s3_asset_bucket_versioning
  s3_bucket_encryption_type = var.s3_asset_bucket_encryption_type
  s3_public_access_block    = var.s3_asset_public_access_block
  s3_force_destroy          = var.s3_asset_force_destroy

  tags = var.common_tags
}


module "rds" {
  source = "./modules/rds"

  database_identifier       = var.database_identifier
  database_name             = var.database_name
  master_username           = var.master_username
  engine_version            = var.engine_version
  parameter_group_family    = var.parameter_group_family
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  max_allocated_storage     = var.max_allocated_storage
  storage_type              = var.storage_type
  database_port             = var.database_port
  backup_retention_period   = var.backup_retention_period
  multi_az                  = var.multi_az
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier


  private_subnet_ids = [
    module.subnets["private_a"].subnet_id,
    module.subnets["private_b"].subnet_id
  ]

  security_group_ids = [
    module.security_group["rds"].security_group_id
  ]

  common_tags = var.common_tags
}

module "app_secret" {
  source = "./modules/secrets_manager"

  secret_name             = var.app_secret_name
  recovery_window_in_days = var.app_secret_recovery_window_in_days

  tags = var.common_tags
}



module "alb" {
  source = "./modules/alb"

  alb_name           = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_load_balancer_type

  security_group_ids = [
    module.security_group["alb"].security_group_id
  ]

  subnet_ids = [
    module.subnets["public_a"].subnet_id,
    module.subnets["public_b"].subnet_id
  ]

  tags = var.common_tags
}

module "target_groups" {

  for_each = var.target_groups
  source   = "./modules/target_group"


  target_group_name              = each.value.name
  target_group_port              = each.value.port
  target_group_protocol          = each.value.protocol
  target_group_type              = each.value.target_type
  target_group_health_check_path = each.value.health_check_path

  vpc_id = module.vpc.vpc_id
  tags   = var.common_tags
}

module "alb_listener" {
  source = "./modules/alb_listener"

  load_balancer_arn        = module.alb.alb_arn
  listener_port            = var.alb_listener_port
  listener_protocol        = var.alb_listener_protocol
  default_target_group_arn = module.target_groups["storefront"].target_group_arn
}



module "alb_listener_rule" {
  source = "./modules/alb_listener_rule"

  listener_arn     = module.alb_listener.listener_arn
  priority         = var.alb_listener_rule_priority
  path_patterns    = var.alb_listener_rule_path_patterns
  target_group_arn = module.target_groups["api"].target_group_arn
}


module "ecs_service" {
  for_each = var.ecs_services
  source   = "./modules/ecs_services"

  service_name        = each.value.service_name
  cluster_arn         = module.ecs_cluster["production"].cluster_arn
  task_definition_arn = module.ecs_task_definition[each.key].task_definition_arn
  desired_count       = each.value.desired_count

  subnet_ids = [
    module.subnets["private_a"].subnet_id,
    module.subnets["private_b"].subnet_id
  ]

  security_group_ids = [
    module.security_group["ecs_${each.key}"].security_group_id
  ]
  assign_public_ip = each.value.assign_public_ip
  container_name   = try(each.value.container_name, null)
  container_port   = try(each.value.container_port, null)
  target_group_arn = contains(["api", "storefront"], each.key) ? module.target_groups[each.key].target_group_arn : null
}

module "amp" {
  source = "./modules/amp"

  workspace_alias = var.amp_workspace_alias
  tags            = var.common_tags
}


module "ecs_task_role" {
  for_each = var.ecs_task_roles

  source = "./modules/ecs_task_roles"

  role_name              = each.value.role_name
  amp_workspace_arn      = module.amp.workspace_arn
  enable_s3_asset_access = contains(["api", "worker"], each.key)

  s3_asset_bucket_arn = contains(
    ["api", "worker"],
    each.key
  ) ? module.s3_asset_bucket.bucket_arn : null


  enable_ses_email_access = each.key == "worker"

  ses_identity_arn = each.key == "worker" ? module.ses.arn : null


  tags = var.common_tags
}


module "grafana_iam_role" {
  source = "./modules/grafana_iam_role"

  role_name         = var.grafana_role_name
  amp_workspace_arn = module.amp.workspace_arn
  tags              = var.common_tags
}

module "grafana" {
  source = "./modules/grafana"

  providers = {
    aws = aws.grafana
  }

  workspace_name           = var.grafana_workspace_name
  authentication_providers = var.grafana_authentication_providers
  account_access_type      = var.grafana_account_access_type
  permission_type          = var.grafana_permission_type

  role_arn       = module.grafana_iam_role.role_arn
  admin_user_ids = var.grafana_admin_user_ids

  tags = var.common_tags
}


module "ses" {
  source = "./modules/ses"

  email_identity = var.ses_email_identity
}
