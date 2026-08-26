variable "s3_bucket_name" {
  description = "Should give an unique name for the s3 bucket"
  type        = string


  validation {
    condition = (
      length(var.s3_bucket_name) >= 3 &&
      length(var.s3_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_name))
    )

    error_message = "S3 bucket name must be between 3 and 63 characters and contain only lowercase letters, numbers, periods, and hyphens."
  }
}


variable "s3_bucket_versioning" {
  description = "Bucket versioning should be enabled"
  type        = bool
}

variable "s3_bucket_encryption_type" {
  description = "Bucket encryption should be enabled"
  type        = string

  validation {
    condition = contains(
      ["AES256", "aws:kms"],
      var.s3_bucket_encryption_type
    )

    error_message = "S3 bucket encryption type must be either AES256 or aws:kms."
  }
}

variable "s3_public_access_block" {
  description = "S3 Public access should be enabled"

  type = object({
    block_public_acls       = bool
    ignore_public_acls      = bool
    block_public_policy     = bool
    restrict_public_buckets = bool
  })
}

variable "s3_force_destroy" {
  description = "Whether Terraform can delete the S3 bucket even when it contains objects"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
}
