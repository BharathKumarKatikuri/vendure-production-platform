resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.cpu
  memory             = var.memory
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    merge(
      {
        name      = var.container_name
        image     = var.container_image
        essential = true

        environment = [
          for name, value in var.environment : {
            name  = name
            value = value
          }
        ]

        secrets = [
          for name, value_from in var.secrets : {
            name      = name
            valueFrom = value_from
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"

          options = {
            "awslogs-group"         = var.log_group_name
            "awslogs-region"        = var.aws_region
            "awslogs-stream-prefix" = var.container_name
          }
        }
      },

      length(var.container_command) > 0 ? {
        command = var.container_command
      } : {},

      var.container_port != null ? {
        portMappings = [
          {
            containerPort = var.container_port
            hostPort      = var.container_port
            protocol      = "tcp"
          }
        ]
      } : {}
    )
  ])

  tags = merge(
    var.tags,
    {
      Name = var.family
    }
  )
}
