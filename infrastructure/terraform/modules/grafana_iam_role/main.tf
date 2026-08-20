data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
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

data "aws_iam_policy_document" "amp_query" {
  statement {
    effect = "Allow"

    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata"
    ]

    resources = [
      var.amp_workspace_arn
    ]
  }
}

resource "aws_iam_role_policy" "amp_query" {
  name   = "${var.role_name}-amp-query"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.amp_query.json
}


data "aws_iam_policy_document" "cloudwatch_read" {
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAlarms"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_read" {
  name   = "${var.role_name}-cloudwatch-read"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.cloudwatch_read.json
}
