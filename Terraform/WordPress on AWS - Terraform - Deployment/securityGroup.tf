# Create Security Group for WordPress
resource "aws_security_group" "wordpress-tf-sg" {
  name        = "wordpress-tf-sg"
  description = "Allow HTTP and SSH access to the WordPress instance"
  vpc_id      = aws_vpc.wordpress-tf-vpc.id
  depends_on  = [aws_vpc.wordpress-tf-vpc]

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-sg"
  })
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