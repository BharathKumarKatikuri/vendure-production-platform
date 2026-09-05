output "arn" {
  value = aws_sesv2_email_identity.this.arn
}

output "email_identity" {
  value = aws_sesv2_email_identity.this.email_identity
}

output "verification_status" {
  value = aws_sesv2_email_identity.this.verification_status
}

output "verified_for_sending_status" {
  value = aws_sesv2_email_identity.this.verified_for_sending_status
}
