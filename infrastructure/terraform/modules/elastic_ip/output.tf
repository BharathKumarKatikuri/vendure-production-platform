output "allocation_id" {
  description = "Allocation ID of the Elastic IP"
  value       = aws_eip.nat.id
}

output "public_ip" {
  description = "Public IPv4 address allocated by AWS"
  value       = aws_eip.nat.public_ip
}
