/*
Component:
- VPC, like "house": (10.0.0.0/16),The boundary of your private network. ,AWS Cloud
- Internet Gateway, "front door": The bridge between your VPC and the Public Internet. ,Attached to VPC
- Public Subnet, "room": A subset of the VPC IP range (10.0.101.0/24). ,Resides inside VPC
- Route Table, "pathway": "The "GPS" that directs traffic from 0.0.0.0/0 to the IGW." ,Linked to VPC
- RT Association,The glue that applies the routing rules to your specific subnet. ,Connects Subnet to RT
*/

locals {
  # This value will change on every apply
  current_time_apply = timestamp()
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block           = var.vpc_cidr # Use the variable declared in Step 2
  enable_dns_hostnames = true
  enable_dns_support   = true
  #   instance_tenancy = "default"

  tags = {
    Name        = "tf_vpc-${local.current_time_apply}"
    Environment = "TF_development_VPC"
  }
}