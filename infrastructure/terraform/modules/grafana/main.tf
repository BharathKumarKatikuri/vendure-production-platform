resource "aws_grafana_workspace" "this" {
  name                     = var.workspace_name
  account_access_type      = var.account_access_type
  authentication_providers = var.authentication_providers
  permission_type          = var.permission_type
  role_arn                 = var.role_arn

  tags = var.tags
}

resource "aws_grafana_role_association" "admin" {
  workspace_id = aws_grafana_workspace.this.id
  role         = "ADMIN"
  user_ids     = var.admin_user_ids
}
