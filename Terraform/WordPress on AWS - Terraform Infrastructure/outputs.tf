output "instance_public_ip" {
  description = "Public IP of the WordPress EC2 instance"
  value       = aws_instance.wordpress-tf-instance.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.wordpress-tf-instance.id
}
