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

  subnet_ids = toset([
    for key, subnet in var.subnets :
    module.subnets[key].subnet_id
    if subnet.public
  ])
}

module "private_route_table_a" {
  source                 = "./modules/route_tables"
  vpc_id                 = module.vpc.vpc_id
  route_table_name       = var.private_route_table_a_name
  destination_cidr_block = var.destination_cidr_block

  igw_id         = null
  nat_gateway_id = module.nat_gateway["nat_a"].nat_gateway_id

  subnet_ids = toset([
    module.subnets["private_a"].subnet_id
  ])
}

module "private_route_table_b" {
  source = "./modules/route_tables"

  vpc_id                 = module.vpc.vpc_id
  route_table_name       = var.private_route_table_b_name
  destination_cidr_block = var.destination_cidr_block

  igw_id         = null
  nat_gateway_id = module.nat_gateway["nat_b"].nat_gateway_id

  subnet_ids = toset([
    module.subnets["private_b"].subnet_id
  ])
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
}

module "ecs_task_definition" {
  for_each = var.ecs_task_definition

  source = "./modules/ecs_task_definition"

  family          = each.value.family
  container_name  = each.value.container_name
  container_image = each.value.container_image
  container_port  = each.value.container_port
  cpu             = each.value.cpu
  memory          = each.value.memory
}


