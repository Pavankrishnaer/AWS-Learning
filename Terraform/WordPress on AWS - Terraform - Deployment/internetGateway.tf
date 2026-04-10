# Create Internet Gateway
resource "aws_internet_gateway" "wordpress-tf-igw" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-igw"
  })
}