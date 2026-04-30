# WordPress Instance
output "wordpress_instance_id" {
  value = aws_instance.wordpress-tf-instance.id
}

# Bastion Host Instance
output "bastion_instance_id" {
  value = aws_instance.bastion-tf-instance.id
}

# WordPress Instance
output "wordpress_instance_public_ip" {
  value = aws_instance.wordpress-tf-instance.public_ip
}

# WordPress URL
output "wordpress_url" {
  value = "http://${aws_instance.wordpress-tf-instance.public_ip}"
}

# VPC ID
output "vpc_id" {
  value = aws_vpc.wordpress-tf-vpc.id
}

# Public Subnet ID
output "public_subnet_id" {
  value = aws_subnet.wordpress-tf-public-subnet.id
}

# Private Subnet ID
output "private_subnet_id" {
  value = aws_subnet.wordpress-tf-private-subnet.id
}