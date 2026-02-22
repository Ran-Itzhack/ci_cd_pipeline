# "data" - data sources are a read-only mechanism used to fetch or compute data from external systems.
# 1. Dynamically find the latest Ubuntu 24.04 AMI in us-west-2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  /*
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  */
}

data "aws_region" "current" {

}

/* 
data "aws_subnets" "default_subnets" {
 filter {
  name = "vpc-id"
  values = [data.aws_vpc.vpc.id]
 }
}

data "aws_subnet" "public_subnet" {
 id = data.aws_subnets.default_subnets.ids[0] // this will fetch first subnet
}
 */