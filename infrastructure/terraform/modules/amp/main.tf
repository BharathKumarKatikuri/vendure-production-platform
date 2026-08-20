resource "aws_prometheus_workspace" "this" {
  alias = var.workspace_alias
  tags  = var.tags
}
