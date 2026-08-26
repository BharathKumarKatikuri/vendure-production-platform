variable "secret_name" {
  description = "Name of the AWS Secrets Manager secret."
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days AWS Secrets Manager waits before permanently deleting the secret."
  type        = number


  validation {
    condition = (
      var.recovery_window_in_days == 0 ||
      (
        var.recovery_window_in_days >= 7 &&
        var.recovery_window_in_days <= 30
      )
    )

    error_message = "recovery_window_in_days must be 0 or between 7 and 30 days."
  }
}

variable "tags" {
  description = "Tags to apply to the Secrets Manager secret."
  type        = map(string)
  default     = {}
}
