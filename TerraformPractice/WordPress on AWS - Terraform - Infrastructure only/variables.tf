variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "vockey"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2" # Change according to your region
}
