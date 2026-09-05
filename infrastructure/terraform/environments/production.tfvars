aws_region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"

vpc_name = "vendure-production"

subnets = {
  public_a = {
    cidr   = "10.0.1.0/24"
    az     = "ap-south-1a"
    public = true
    name   = "public_subnet_a"
  }

  public_b = {
    cidr   = "10.0.2.0/24"
    az     = "ap-south-1b"
    public = true
    name   = "public_subnet_b"
  }

  private_a = {
    cidr   = "10.0.3.0/24"
    az     = "ap-south-1a"
    public = false
    name   = "private_subnet_a"
  }

  private_b = {
    cidr   = "10.0.4.0/24"
    az     = "ap-south-1b"
    public = false
    name   = "private_subnet_b"
  }
}


igw_name = "vendure-production-igw"


public_route_table_name = "vendure-production-public-rt"

private_route_table_a_name = "vendure-production-private-a-rt"

private_route_table_b_name = "vendure-production-private-b-rt"

destination_cidr_block = "0.0.0.0/0"

elastic_ips = {
  nat_a = {
    name = "vendure-production-nat-a-eip"
  }

  nat_b = {
    name = "vendure-production-nat-b-eip"
  }
}

nat_gateways = {
  nat_a = {
    eip_key    = "nat_a"
    subnet_key = "public_a"
    name       = "vendure-production-nat-a"
  }

  nat_b = {
    eip_key    = "nat_b"
    subnet_key = "public_b"
    name       = "vendure-production-nat-b"
  }
}


security_groups = {
  alb = {
    name        = "vendure-production-alb-sg"
    description = "Security Group for Application Load Balancer."
  }

  ecs_api = {
    name        = "vendure-production-ecs-api-sg"
    description = "Security group for the Vendure API ECS tasks."
  }

  ecs_storefront = {
    name        = "vendure-production-ecs-storefront-sg"
    description = "Security group for the Vendure storefront ECS tasks."
  }

  ecs_worker = {
    name        = "vendure-production-ecs-worker-sg"
    description = "Security group for the Vendure worker ECS tasks."
  }

  rds = {
    name        = "vendure-production-rds-sg"
    description = "Security group for the Vendure PostgreSQL RDS instance."
  }
}


ecs_clusters = {
  production = {
    name                       = "vendure-production-cluster"
    container_insights_enabled = true
  }
}



ecs_task_definitions = {
  api = {
    family          = "vendure-api"
    container_name  = "vendure-api"
    container_image = "974268348514.dkr.ecr.ap-south-1.amazonaws.com/vendure-production:3.7.1-e37ceee"
    container_port  = 3000

    container_command = [
      "node",
      "apps/server/dist/index.js"
    ]

    cpu           = 512
    memory        = 1024
    metrics_port  = 3000
    log_group_key = "vendure_api"

    environment = {
      APP_ENV = "production"
      PORT    = "3000"
    }

    secrets = {}
  }

  worker = {
    family          = "vendure-worker"
    container_name  = "vendure-worker"
    container_image = "974268348514.dkr.ecr.ap-south-1.amazonaws.com/vendure-production:3.7.1-e37ceee"

    container_command = [
      "node",
      "apps/server/dist/index-worker.js"
    ]

    cpu           = 512
    memory        = 1024
    metrics_port  = 9464
    log_group_key = "vendure_worker"

    environment = {
      APP_ENV = "production"
    }

    secrets = {}
  }

  storefront = {
    family          = "vendure-storefront"
    container_name  = "vendure-storefront"
    container_image = "974268348514.dkr.ecr.ap-south-1.amazonaws.com/vendure-production-storefront:3.7.1-e64ee9f"

    container_port = 3001
    cpu            = 512
    memory         = 1024
    metrics_port   = 3001
    log_group_key  = "vendure_storefront"

    environment = {
      PORT = "3001"
    }

    secrets = {}
  }
}



ecs_task_execution_roles = {
  api = {
    role_name = "vendure-production-ecs-task-execution-role"
  }

  worker = {
    role_name = "vendure-production-worker-ecs-task-execution-role"
  }

  storefront = {
    role_name = "vendure-production-storefront-ecs-task-execution-role"
  }
}



ecr_repositories = {
  server = {
    repository_name = "vendure-production"
  }

  storefront = {
    repository_name = "vendure-production-storefront"
  }
}

ecr_image_tag_mutability = "IMMUTABLE"

ecr_encryption_type = "AES256"


s3_asset_bucket_name            = "vendure-production-assets-974268348514"
s3_asset_bucket_versioning      = true
s3_asset_bucket_encryption_type = "AES256"

s3_asset_public_access_block = {
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

s3_asset_force_destroy = false


cloudwatch_log_groups = {
  vendure_api = {
    log_group_name = "/ecs/vendure-production/api"

    retention_in_days = 30
  }


  vendure_worker = {
    log_group_name    = "/ecs/vendure-production/worker"
    retention_in_days = 30
  }

  vendure_storefront = {
    log_group_name    = "/ecs/vendure-production/storefront"
    retention_in_days = 30
  }

  adot = {
    log_group_name    = "/ecs/vendure-production/adot"
    retention_in_days = 30
  }
}

common_tags = {
  Project     = "vendure-production-platform"
  Environment = "production"
  ManagedBy   = "terraform"
}

database_identifier = "vendure-production-postgres"
database_name       = "venduredb"
master_username     = "vendure_admin"

engine_version         = "16"
parameter_group_family = "postgres16"

instance_class = "db.t4g.micro"

allocated_storage     = 20
max_allocated_storage = 100
storage_type          = "gp3"

database_port = 5432

backup_retention_period = 7

multi_az                  = false
deletion_protection       = false
skip_final_snapshot       = true
final_snapshot_identifier = null



alb_name               = "vendure-production-alb"
alb_internal           = false
alb_load_balancer_type = "application"


target_groups = {
  api = {
    name              = "vendure-api-tg"
    port              = 3000
    protocol          = "HTTP"
    target_type       = "ip"
    health_check_path = "/health"
  }

  storefront = {
    name              = "vendure-storefront-tg"
    port              = 3001
    protocol          = "HTTP"
    target_type       = "ip"
    health_check_path = "/health"
  }
}

alb_listener_port     = 80
alb_listener_protocol = "HTTP"


alb_listener_rule_priority = 100

alb_listener_rule_path_patterns = [
  "/shop-api*",
  "/admin-api*",
  "/assets*",
  "/dashboard*"
]

ecs_services = {
  api = {
    service_name     = "vendure-api-service"
    desired_count    = 0
    assign_public_ip = false
    container_name   = "vendure-api"
    container_port   = 3000
  }

  storefront = {
    service_name     = "vendure-storefront-service"
    desired_count    = 0
    assign_public_ip = false
    container_name   = "vendure-storefront"
    container_port   = 3001
  }

  worker = {
    service_name     = "vendure-worker-service"
    desired_count    = 0
    assign_public_ip = false
  }
}

amp_workspace_alias = "vendure-production-prometheus"


ecs_task_roles = {
  api = {
    role_name = "vendure-production-api-task-role"
  }

  storefront = {
    role_name = "vendure-production-storefront-task-role"
  }

  worker = {
    role_name = "vendure-production-worker-task-role"
  }
}

adot_image = "public.ecr.aws/aws-observability/aws-otel-collector:v0.49.0"

grafana_workspace_name = "vendure-production-grafana"

grafana_authentication_providers = [
  "AWS_SSO"
]

grafana_account_access_type = "CURRENT_ACCOUNT"

grafana_permission_type = "CUSTOMER_MANAGED"

grafana_role_name = "vendure-production-grafana-role"

grafana_admin_user_ids = [
  "69fa059c-9031-705e-00b2-0ce957f6da9e"
]


app_secret_name                    = "vendure-production/app"
app_secret_recovery_window_in_days = 7


grafana_region = "ap-southeast-1"


ses_email_identity = "katikuribharath@gmail.com"
