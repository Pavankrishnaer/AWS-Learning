# Create VPC
resource "aws_vpc" "wordpress-tf-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-vpc"
  })
}