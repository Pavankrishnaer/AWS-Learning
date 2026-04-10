# Create Public Route Table
resource "aws_route_table" "wordpress-tf-public-route-table" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress-tf-igw.id
  }

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-public-route-table"
  })
}

# Create Public Route Table Association
resource "aws_route_table_association" "wordpress-tf-public-route-table-association" {
  subnet_id      = aws_subnet.wordpress-tf-public-subnet.id
  route_table_id = aws_route_table.wordpress-tf-public-route-table.id
}

# Create Private Route Table
resource "aws_route_table" "wordpress-tf-private-route-table" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-private-route-table"
  })
}

# Create Private Route Table Association
resource "aws_route_table_association" "wordpress-tf-private-route-table-association" {
  subnet_id      = aws_subnet.wordpress-tf-private-subnet.id
  route_table_id = aws_route_table.wordpress-tf-private-route-table.id
}