# SSM Parameter for DynamoDB Contacts Table Name
resource "aws_ssm_parameter" "contacts_table_name" {
  name        = "/${var.project_name}/${var.environment}/dynamodb/contacts-table-name"
  description = "DynamoDB Contacts Table Name"
  type        = "String"
  value       = aws_dynamodb_table.contacts.name

  tags = {
    Name        = "${var.project_name}-contacts-table-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SSM Parameter for DynamoDB Orders Table Name
resource "aws_ssm_parameter" "orders_table_name" {
  name        = "/${var.project_name}/${var.environment}/dynamodb/orders-table-name"
  description = "DynamoDB Orders Table Name"
  type        = "String"
  value       = aws_dynamodb_table.orders.name

  tags = {
    Name        = "${var.project_name}-orders-table-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SSM Parameter for DynamoDB Newsletter Table Name
resource "aws_ssm_parameter" "newsletter_table_name" {
  name        = "/${var.project_name}/${var.environment}/dynamodb/newsletter-table-name"
  description = "DynamoDB Newsletter Table Name"
  type        = "String"
  value       = aws_dynamodb_table.newsletter.name

  tags = {
    Name        = "${var.project_name}-newsletter-table-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SSM Parameter for CloudFront Distribution URL
resource "aws_ssm_parameter" "cloudfront_url" {
  name        = "/${var.project_name}/${var.environment}/cloudfront/distribution-url"
  description = "CloudFront Distribution URL"
  type        = "String"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"

  tags = {
    Name        = "${var.project_name}-cloudfront-url-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SSM Parameter for S3 Website Bucket Name
resource "aws_ssm_parameter" "website_bucket_name" {
  name        = "/${var.project_name}/${var.environment}/s3/website-bucket-name"
  description = "S3 Website Bucket Name"
  type        = "String"
  value       = aws_s3_bucket.website.id

  tags = {
    Name        = "${var.project_name}-s3-bucket-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SNS Topic ARN for Order Notifications (System Alerts)
resource "aws_ssm_parameter" "sns_topic_arn" {
  name        = "/${var.project_name}/${var.environment}/sns/order-notifications-topic-arn"
  description = "SNS Topic ARN for Order Notifications"
  type        = "String"
  value       = aws_sns_topic.order_notifications.arn

  tags = {
    Name        = "${var.project_name}-sns-topic-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SNS Topic ARN for Order Alerts (used by Lambda) - SAME TOPIC
resource "aws_ssm_parameter" "sns_order_alerts_topic_arn" {
  name        = "/${var.project_name}/${var.environment}/sns/order-alerts-topic-arn"
  description = "SNS Topic ARN for Order Alerts (Lambda order handler)"
  type        = "String"
  value       = aws_sns_topic.order_notifications.arn # ← Using same topic

  tags = {
    Name        = "${var.project_name}-sns-order-alerts-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SQS Queue URL
resource "aws_ssm_parameter" "sqs_queue_url" {
  name        = "/${var.project_name}/${var.environment}/sqs/order-processing-queue-url"
  description = "SQS Queue URL for Order Processing"
  type        = "String"
  value       = aws_sqs_queue.order_processing.url

  tags = {
    Name        = "${var.project_name}-sqs-queue-param"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SES Sender Email
resource "aws_ssm_parameter" "ses_sender_email" {
  name        = "/${var.project_name}/${var.environment}/ses/sender-email"
  description = "SES Verified Sender Email"
  type        = "String"
  value       = aws_ses_email_identity.sender.email

  tags = {
    Name        = "${var.project_name}-ses-email-param"
    Project     = var.project_name
    Environment = var.environment
  }
}