data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "secrets_access" {
  count = length(var.secret_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = var.secret_arns
  }
}


resource "aws_iam_policy" "secrets_access" {
  count = length(var.secret_arns) > 0 ? 1 : 0

  name   = "${var.role_name}-secrets-access"
  policy = data.aws_iam_policy_document.secrets_access[0].json

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "secrets_access" {
  count = length(var.secret_arns) > 0 ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}

