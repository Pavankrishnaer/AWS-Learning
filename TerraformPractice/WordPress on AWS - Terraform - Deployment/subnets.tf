# Create Public Subnet
resource "aws_subnet" "wordpress-tf-public-subnet" {
  vpc_id     = aws_vpc.wordpress-tf-vpc.id
  cidr_block = "192.168.0.0/28"

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-public-subnet"
  })
}

# Create Private Subnet
resource "aws_subnet" "wordpress-tf-private-subnet" {
  vpc_id     = aws_vpc.wordpress-tf-vpc.id
  cidr_block = "192.168.0.16/28"

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-private-subnet"
  })
}