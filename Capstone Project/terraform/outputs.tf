# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.ellore_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.ellore_vpc.cidr_block
}

output "public_subnet_a_id" {
  description = "ID of public subnet A"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  description = "ID of public subnet B"
  value       = aws_subnet.public_subnet_b.id
}

output "private_subnet_a_id" {
  description = "ID of private subnet A"
  value       = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  description = "ID of private subnet B"
  value       = aws_subnet.private_subnet_b.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.ellore_igw.id
}

# Security Group Outputs
output "lambda_security_group_id" {
  description = "ID of Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "vpc_endpoint_security_group_id" {
  description = "ID of VPC endpoint security group"
  value       = aws_security_group.vpc_endpoint_sg.id
}

# Budget Outputs
output "budget_name" {
  description = "Name of the AWS Budget"
  value       = aws_budgets_budget.monthly_budget.name
}

output "budget_sns_topic_arn" {
  description = "ARN of the budget alerts SNS topic"
  value       = aws_sns_topic.budget_alerts.arn
}

# S3 Website Outputs
output "website_bucket_name" {
  description = "Name of the S3 website bucket"
  value       = aws_s3_bucket.website.id
}

output "website_bucket_arn" {
  description = "ARN of the S3 website bucket"
  value       = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  description = "S3 website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_url" {
  description = "Full S3 website URL"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_url" {
  description = "Full CloudFront HTTPS URL"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

# DynamoDB Table Outputs
output "dynamodb_contacts_table_name" {
  description = "Name of the contacts DynamoDB table"
  value       = aws_dynamodb_table.contacts.name
}

output "dynamodb_contacts_table_arn" {
  description = "ARN of the contacts DynamoDB table"
  value       = aws_dynamodb_table.contacts.arn
}

output "dynamodb_orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.name
}

output "dynamodb_orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.arn
}

output "dynamodb_newsletter_table_name" {
  description = "Name of the newsletter DynamoDB table"
  value       = aws_dynamodb_table.newsletter.name
}

output "dynamodb_newsletter_table_arn" {
  description = "ARN of the newsletter DynamoDB table"
  value       = aws_dynamodb_table.newsletter.arn
}

# SSM Parameter Outputs
output "ssm_contacts_table_param_name" {
  description = "SSM Parameter name for contacts table"
  value       = aws_ssm_parameter.contacts_table_name.name
}

output "ssm_orders_table_param_name" {
  description = "SSM Parameter name for orders table"
  value       = aws_ssm_parameter.orders_table_name.name
}

output "ssm_newsletter_table_param_name" {
  description = "SSM Parameter name for newsletter table"
  value       = aws_ssm_parameter.newsletter_table_name.name
}

output "ssm_cloudfront_url_param_name" {
  description = "SSM Parameter name for CloudFront URL"
  value       = aws_ssm_parameter.cloudfront_url.name
}

# Lambda IAM Role Outputs
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

# Lambda Function Outputs
output "lambda_contact_handler_arn" {
  description = "ARN of the contact handler Lambda function"
  value       = aws_lambda_function.contact_handler.arn
}

output "lambda_contact_handler_name" {
  description = "Name of the contact handler Lambda function"
  value       = aws_lambda_function.contact_handler.function_name
}

output "lambda_order_handler_arn" {
  description = "ARN of the order handler Lambda function"
  value       = aws_lambda_function.order_handler.arn
}

output "lambda_order_handler_name" {
  description = "Name of the order handler Lambda function"
  value       = aws_lambda_function.order_handler.function_name
}

output "lambda_newsletter_handler_arn" {
  description = "ARN of the newsletter handler Lambda function"
  value       = aws_lambda_function.newsletter_handler.arn
}

output "lambda_newsletter_handler_name" {
  description = "Name of the newsletter handler Lambda function"
  value       = aws_lambda_function.newsletter_handler.function_name
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.ellore_api.id
}

output "api_gateway_invoke_url" {
  description = "Base URL for API Gateway endpoints"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_contact_endpoint" {
  description = "Full URL for contact endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/contact"
}

output "api_order_endpoint" {
  description = "Full URL for order endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/order"
}

output "api_newsletter_endpoint" {
  description = "Full URL for newsletter endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/newsletter"
}

# SQS Queue Outputs
output "sqs_order_queue_url" {
  description = "URL of the order processing SQS queue"
  value       = aws_sqs_queue.order_processing.url
}

output "sqs_order_queue_arn" {
  description = "ARN of the order processing SQS queue"
  value       = aws_sqs_queue.order_processing.arn
}

output "sqs_fifo_queue_url" {
  description = "URL of the FIFO order processing queue"
  value       = aws_sqs_queue.order_processing_fifo.url
}

# SNS Topic Outputs
output "sns_order_notifications_arn" {
  description = "ARN of the order notifications SNS topic"
  value       = aws_sns_topic.order_notifications.arn
}

output "sns_system_alerts_arn" {
  description = "ARN of the system alerts SNS topic"
  value       = aws_sns_topic.system_alerts.arn
}

# SES Outputs
output "ses_sender_email" {
  description = "SES verified sender email address"
  value       = aws_ses_email_identity.sender.email
}

output "ses_verification_status" {
  description = "SES email verification status"
  value       = "Check your email inbox for verification link"
}

# EventBridge Outputs
output "eventbridge_daily_sales_rule" {
  description = "Name of daily sales report EventBridge rule"
  value       = aws_cloudwatch_event_rule.daily_sales_report.name
}

output "eventbridge_weekly_newsletter_rule" {
  description = "Name of weekly newsletter EventBridge rule"
  value       = aws_cloudwatch_event_rule.weekly_newsletter.name
}

output "eventbridge_flash_sale_rule" {
  description = "Name of flash sale EventBridge rule"
  value       = aws_cloudwatch_event_rule.flash_sale_reminder.name
}

# Translation Endpoint Output
output "api_translate_endpoint" {
  description = "Full URL for translation endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/translate"
}

# CloudWatch Outputs
output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.ellore_dashboard.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ellore_dashboard.dashboard_name}"
}