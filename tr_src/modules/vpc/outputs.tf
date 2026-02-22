output "vpc_id" {
  description = "The ID of the VPC"
  # This must match the resource type and name inside your VPC module
  value       = aws_vpc.terraform_vpc.id 
}