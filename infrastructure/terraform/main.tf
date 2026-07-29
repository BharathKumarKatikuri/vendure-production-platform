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
module "pivate_route_table_a" {
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
  ingress_rules       = each.value.ingress_rules
  egress_rules        = each.value.egress_rules
}


module "ecs_cluster" {
  for_each = var.ecs_clusters

  source = "./modules/ecs_cluster"

  cluster_name               = each.value.name
  container_insights_enabled = each.value.container_insights_enabled
  tags                       = var.common_tags
}

module "ecs_task_definitions" {
  for_each = var.ecs_task_definitions

  source = "./modules/ecs_task_definition"

  family            = each.value.family
  container_name    = each.value.container_name
  container_image   = each.value.container_image
  container_port    = each.value.container_port
  container_command = each.value.container_command
  cpu               = each.value.cpu
  memory            = each.value.memory

  execution_role_arn = module.ecs_task_execution_role.role_arn

  log_group_name = module.cloudwatch_log_group[each.value.log_group_key].log_group_name
  aws_region     = var.aws_region

  environment = each.value.environment
  secrets     = each.value.secrets
  tags        = var.common_tags
}


module "ecs_task_execution_role" {
  source = "./modules/ecs_task_execution_role"

  role_name = var.ecs_task_execution_role_name
}

module "cloudwatch_log_group" {
  for_each = var.cloudwatch_log_groups

  source = "./modules/cloudwatch_log_group"

  log_group_name    = each.value.log_group_name
  retention_in_days = each.value.retention_in_days
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  scan_on_push         = var.ecr_scan_on_push
  image_tag_mutability = var.ecr_image_tag_mutability
  encryption_type      = var.ecr_encryption_type

  tags = merge(
    var.common_tags,
    {
      Name = var.ecr_repository_name
    }
  )
}

