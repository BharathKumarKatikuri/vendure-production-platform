resource "aws_grafana_workspace" "this" {
  name                     = var.workspace_name
  account_access_type      = var.account_access_type
  authentication_providers = var.authentication_providers
  permission_type          = var.permission_type
  role_arn                 = var.role_arn

  tags = var.tags
}


