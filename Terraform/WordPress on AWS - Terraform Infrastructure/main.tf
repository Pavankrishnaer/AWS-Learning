# Terraform Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "wordpress-tf-vpc" {
  cidr_block = "192.168.0.0/27"
  tags = {
    Name        = "wordpress-tf-vpc"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Public Subnet
resource "aws_subnet" "wordpress-tf-public-subnet" {
  vpc_id     = aws_vpc.wordpress-tf-vpc.id
  cidr_block = "192.168.0.0/28"

  tags = {
    Name        = "wordpress-tf-public-subnet"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Private Subnet
resource "aws_subnet" "wordpress-tf-private-subnet" {
  vpc_id     = aws_vpc.wordpress-tf-vpc.id
  cidr_block = "192.168.0.16/28"

  tags = {
    Name        = "wordpress-tf-private-subnet"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Public Route Table
resource "aws_route_table" "wordpress-tf-public-route-table" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress-tf-igw.id
  }

  tags = {
    Name        = "wordpress-tf-public-route-table"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Private Route Table
resource "aws_route_table" "wordpress-tf-private-route-table" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  tags = {
    Name        = "wordpress-tf-private-route-table"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Public Route Table Association
resource "aws_route_table_association" "wordpress-tf-public-route-table-association" {
  subnet_id      = aws_subnet.wordpress-tf-public-subnet.id
  route_table_id = aws_route_table.wordpress-tf-public-route-table.id
}

# Create Private Route Table Association
resource "aws_route_table_association" "wordpress-tf-private-route-table-association" {
  subnet_id      = aws_subnet.wordpress-tf-private-subnet.id
  route_table_id = aws_route_table.wordpress-tf-private-route-table.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "wordpress-tf-igw" {
  vpc_id = aws_vpc.wordpress-tf-vpc.id

  tags = {
    Name        = "wordpress-tf-igw"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Security Group for WordPress
resource "aws_security_group" "wordpress-tf-sg" {
  name        = "wordpress-tf-sg"
  description = "Allow HTTP and SSH access to the WordPress instance"
  vpc_id      = aws_vpc.wordpress-tf-vpc.id
  depends_on  = [aws_vpc.wordpress-tf-vpc]

  tags = {
    Name        = "wordpress-tf-sg"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Create Ingress Rule for HTTP
resource "aws_vpc_security_group_ingress_rule" "wordpress-tf-sg-allow-http" {
  security_group_id = aws_security_group.wordpress-tf-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Create Ingress Rule for SSH
resource "aws_vpc_security_group_ingress_rule" "wordpress-tf-sg-allow-ssh" {
  security_group_id = aws_security_group.wordpress-tf-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create Ingress Rule for MySQL
resource "aws_vpc_security_group_ingress_rule" "wordpress-tf-sg-allow-mysql" {
  security_group_id = aws_security_group.wordpress-tf-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

# Create Egress Rule for allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "wordpress-tf-sg-allow-all-outbound" {
  security_group_id = aws_security_group.wordpress-tf-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Create EC2 Instance
resource "aws_instance" "wordpress-tf-instance" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.wordpress-tf-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.wordpress-tf-sg.id]
  depends_on                  = [aws_vpc.wordpress-tf-vpc, aws_subnet.wordpress-tf-public-subnet, aws_security_group.wordpress-tf-sg]

  tags = {
    Name        = "wordpress-tf-instance"
    Project     = "wordpress-tf"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
