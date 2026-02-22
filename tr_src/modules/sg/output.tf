output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_ssh_http_https_terraform.id
}
