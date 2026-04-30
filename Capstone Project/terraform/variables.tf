variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "ellore"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "capstone"
}