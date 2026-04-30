# Local tags

locals {
  common_tags = {
    Project     = "wordpress-deployment-tf"
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}