terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.1.7"

  ##
  # Updated to match your first error fix:
  ##

  # required_version = ">= 1.4.0" 

}

provider "aws" {
  alias      = "ohio"
  region     = "us-east-2"
  # access_key = var.access_key
  # secret_key = var.secret_key
}


# module "vpc" {
#   source   = "./modules/vpc"
#   vpc_cidr = var.vpc_cidr
# }

# module "sg" {
#   source = "./modules/sg"
#   vpc_id = module.vpc.vpc_id
# }

# module "ec2" {
#   source = "./modules/ec2"
#   vpc_id = module.vpc.vpc_id
#   sg_id = module.sg.security_group_id # Pass the output from the SG module into the EC2 variable
# }


data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user_id" {
  value = data.aws_caller_identity.current.user_id
}




resource "null_resource" "create_file_localy" {
  provisioner "local-exec" {

    # command = "echo 'Automate AWS Infra Deployment ${join(", ", data.aws_subnets.example.ids)} using Terraform...' > hello.txt"
    # command = "echo -e 'Automate AWS Infra Deployment\n${join(", ", data.aws_subnets.example.ids)}\nusing Terraform and GitHub Actions Workflows' > hello.txt"
    command = <<EOT
                  echo 'AWS User Account Info : ${ jsonencode(data.aws_caller_identity.current) }\n' > aws_user_account_info.txt
                EOT
  }
}