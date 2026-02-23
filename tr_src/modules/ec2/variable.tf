variable "vpc_id" {
  type        = string
  description = "The ID of the VPC from the other module"
}

variable "sg_id" {
  type        = string
  description = "The ID of the security group from the SG module"
}
# 1. Register the public key with AWS
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/cicd_terraform_github_action.pub")
}