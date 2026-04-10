# EC2 Key Pair Name
variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "vockey"
}

# EC2 Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

# AWS Region
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2" # Change according to your region
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "192.168.0.0/27"
}
