/*

Component:
- VPC, like "house": (10.0.0.0/16),The boundary of your private network. AWS Cloud
- Internet Gateway, like "front door": The bridge between your VPC and the Public Internet. Attached to VPC
- Public Subnet, like "room": A subset of the VPC IP range (10.0.101.0/24). Resides inside VPC
- Route Table, like "pathway": "The ""GPS"" that directs traffic from 0.0.0.0/0 to the IGW." Linked to VPC
- RT Association,The glue that applies the routing rules to your specific subnet. Connects Subnet to RT

*/


# Create the EC2 Instance using the data source ID
resource "aws_instance" "ubuntu_ec2_instance_terraform" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id                   = aws_subnet.tf_subnet_public.id
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = true
  
  tags = {
    Name = "aws-ec2-instance-terraform"
  }

  user_data = file("${path.module}/setup_nginx.sh")
}


# Define the Internet Gateway resource and attach it to the VPC
resource "aws_internet_gateway" "terraform_gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "terraform_internet_gateway"
    Environment = "TF_development_internet_gateway"
  }
}

# Public subnet
resource "aws_subnet" "tf_subnet_public" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true

  # count                   = length(var.public_subnets_cidr)
  # availability_zone       = element(local.availability_zones, count.index)

  tags = {
    Name = "terraform_subnet_public"
    Environment = "TF_development_subnet_public"
  }
}


resource "aws_route_table" "terraform_rt_public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_gw.id
  }

  tags = {
    Name  = "terraform__rt-public"
    Environment = "TF_development_rt_public"
  }
}

#  Associate route tables for subnets
resource "aws_route_table_association" "terraform_rta_public" {
  subnet_id      = aws_subnet.tf_subnet_public.id
  route_table_id = aws_route_table.terraform_rt_public.id
}


output "ec2_ip_address" {
  value = aws_instance.ubuntu_ec2_instance_terraform.public_ip
}

