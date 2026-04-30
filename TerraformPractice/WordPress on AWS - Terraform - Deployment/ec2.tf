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
  user_data                   = file("scripts/userdata.sh")

  tags = merge(local.common_tags, {
    Name = "wordpress-tf-instance"
  })
}

# Create Bastion Host Instance
resource "aws_instance" "bastion-tf-instance" {
  ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.wordpress-tf-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.wordpress-tf-sg.id]

  tags = merge(local.common_tags, {
    Name = "bastion-tf-instance"
  })
}