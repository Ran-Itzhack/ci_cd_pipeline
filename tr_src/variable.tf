

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type        = string
  default     = "10.0.0.0/16"
}

# variable "subnet_cidr" {
#     description = "Subnet CIDRS"
#     type = list(string)
# }