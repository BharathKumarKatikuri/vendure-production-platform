data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}


data "aws_iam_policy_document" "amp_remote_write" {
  statement {
    effect = "Allow"

    actions = [
      "aps:RemoteWrite"
    ]

    resources = [
      var.amp_workspace_arn
    ]
  }
}

resource "aws_iam_role_policy" "amp_remote_write" {
  name   = "${var.role_name}-amp-remote-write"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.amp_remote_write.json
}
