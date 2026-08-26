variable "role_name" {
  description = "Name of the IAM role assumed by containers running inside the ECS task."
  type        = string
}

variable "amp_workspace_arn" {
  description = "ARN of the AMP workspace that the ECS task is allowed to write metrics to."
  type        = string
}

variable "enable_s3_asset_access" {
  description = "Whether this ECS task role should receive access to the Vendure asset S3 bucket."
  type        = bool
  default     = false
}

variable "s3_asset_bucket_arn" {
  description = "ARN of the S3 bucket used by Vendure for persistent asset storage."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the ECS task IAM role."
  type        = map(string)
  default     = {}
}
