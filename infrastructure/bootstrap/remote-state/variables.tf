variable "aws_region" {
  description = "AWS region where the remote-state S3 bucket will be created."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique name of the S3 bucket used to store Terraform state."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to the remote-state resources."
  type        = map(string)
  default     = {}
}
