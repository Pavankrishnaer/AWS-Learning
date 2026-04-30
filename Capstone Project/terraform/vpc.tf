# VPC
resource "aws_vpc" "ellore_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ellore_igw" {
  vpc_id = aws_vpc.ellore_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Public Subnet A (us-west-2a)
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.ellore_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-a"
    Project     = var.project_name
    Environment = var.environment
    Type        = "Public"
  }
}

# Public Subnet B (us-west-2b)
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.ellore_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-b"
    Project     = var.project_name
    Environment = var.environment
    Type        = "Public"
  }
}

# Private Subnet A (us-west-2a)
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.ellore_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-subnet-a"
    Project     = var.project_name
    Environment = var.environment
    Type        = "Private"
  }
}

# Private Subnet B (us-west-2b)
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.ellore_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-subnet-b"
    Project     = var.project_name
    Environment = var.environment
    Type        = "Private"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ellore_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ellore_igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Route Table Associations - Public Subnet A
resource "aws_route_table_association" "public_rta_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Associations - Public Subnet B
resource "aws_route_table_association" "public_rta_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table for Private Subnets (no internet access)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ellore_vpc.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Route Table Associations - Private Subnet A
resource "aws_route_table_association" "private_rta_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Route Table Associations - Private Subnet B
resource "aws_route_table_association" "private_rta_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}