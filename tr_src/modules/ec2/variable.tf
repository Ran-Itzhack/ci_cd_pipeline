variable "vpc_id" {
  type        = string
  description = "The ID of the VPC from the other module"
}

variable "sg_id" {
  type        = string
  description = "The ID of the security group from the SG module"
}