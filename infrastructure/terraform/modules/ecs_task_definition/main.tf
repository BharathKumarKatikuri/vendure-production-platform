resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]


  cpu    = var.cpu
  memory = var.memory
  container_definitions = jsonencode([
    {
      # container configuration goes here
    }
  ])
}
