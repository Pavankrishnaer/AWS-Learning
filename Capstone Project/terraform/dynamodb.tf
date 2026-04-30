# DynamoDB Table for Contact Form Submissions
resource "aws_dynamodb_table" "contacts" {
  name         = "${var.project_name}-contacts"
  billing_mode = "PAY_PER_REQUEST" # On-demand pricing (no capacity planning)
  hash_key     = "contactId"

  attribute {
    name = "contactId"
    type = "S" # String
  }

  attribute {
    name = "submittedAt"
    type = "S" # ISO 8601 timestamp string
  }

  # Global Secondary Index for querying by submission date
  global_secondary_index {
    name            = "SubmittedAtIndex"
    hash_key        = "submittedAt"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-contacts"
    Project     = var.project_name
    Environment = var.environment
  }
}

# DynamoDB Table for Orders
resource "aws_dynamodb_table" "orders" {
  name         = "${var.project_name}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  attribute {
    name = "orderDate"
    type = "S"
  }

  # GSI for querying orders by customer
  global_secondary_index {
    name            = "CustomerIdIndex"
    hash_key        = "customerId"
    range_key       = "orderDate"
    projection_type = "ALL"
  }

  # GSI for querying orders by date
  global_secondary_index {
    name            = "OrderDateIndex"
    hash_key        = "orderDate"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-orders"
    Project     = var.project_name
    Environment = var.environment
  }
}

# DynamoDB Table for Newsletter Subscriptions
resource "aws_dynamodb_table" "newsletter" {
  name         = "${var.project_name}-newsletter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "subscribedAt"
    type = "S"
  }

  # GSI for querying by subscription date
  global_secondary_index {
    name            = "SubscribedAtIndex"
    hash_key        = "subscribedAt"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-newsletter"
    Project     = var.project_name
    Environment = var.environment
  }
}