variable "repository_name" {
  description = "Name of the Amazon ECR repository"

  type = string
}

variable "tags" {
  description = "Tags to apply to the Amazon ECR repository."

  type    = map(string)
  default = {}

}

variable "scan_on_push" {
  description = "Whether images should be automatically scanned for vulnerabilities when pushed"

  type    = bool
  default = true
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."

  type    = string
  default = "MUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )

    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}


variable "encryption_type" {
  description = "Encryption type for the ECR repository."

  type    = string
  default = "AES256"

  validation {
    condition = contains(
      ["AES256", "KMS"],
      var.encryption_type
    )

    error_message = "Encryption type must be either AES256 or KMS."
  }
}
