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


data "aws_iam_policy_document" "s3_asset_access" {
  count = var.enable_s3_asset_access ? 1 : 0

  statement {
    sid    = "ListAssetBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.s3_asset_bucket_arn
    ]
  }

  statement {
    sid    = "ManageAssetObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${var.s3_asset_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_asset_access" {
  count = var.enable_s3_asset_access ? 1 : 0

  name   = "${var.role_name}-s3-asset-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_asset_access[0].json
}



data "aws_iam_policy_document" "ses_email_access" {
  count = var.enable_ses_email_access ? 1 : 0

  statement {
    sid    = "SendVendureEmail"
    effect = "Allow"

    actions = [
      "ses:SendEmail"
    ]

    resources = [
      var.ses_identity_arn
    ]
  }
}

resource "aws_iam_role_policy" "ses_email_access" {
  count = var.enable_ses_email_access ? 1 : 0

  name   = "${var.role_name}-ses-email-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ses_email_access[0].json
}
