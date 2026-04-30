# EventBridge Rule - Daily Sales Report (runs at 9 AM UTC daily)
resource "aws_cloudwatch_event_rule" "daily_sales_report" {
  name                = "${var.project_name}-daily-sales-report"
  description         = "Trigger daily sales report generation at 9 AM UTC"
  schedule_expression = "cron(0 9 * * ? *)" # 9 AM UTC every day

  tags = {
    Name        = "${var.project_name}-daily-sales-rule"
    Project     = var.project_name
    Environment = var.environment
  }
}

# EventBridge Rule - Weekly Newsletter (runs Sunday 10 AM UTC)
resource "aws_cloudwatch_event_rule" "weekly_newsletter" {
  name                = "${var.project_name}-weekly-newsletter"
  description         = "Trigger weekly newsletter send every Sunday at 10 AM UTC"
  schedule_expression = "cron(0 10 ? * SUN *)" # 10 AM UTC every Sunday

  tags = {
    Name        = "${var.project_name}-newsletter-rule"
    Project     = var.project_name
    Environment = var.environment
  }
}

# EventBridge Rule - Flash Sale Reminder (runs every 6 hours)
resource "aws_cloudwatch_event_rule" "flash_sale_reminder" {
  name                = "${var.project_name}-flash-sale-reminder"
  description         = "Trigger flash sale notifications every 6 hours"
  schedule_expression = "rate(6 hours)"

  tags = {
    Name        = "${var.project_name}-flash-sale-rule"
    Project     = var.project_name
    Environment = var.environment
  }
}

# EventBridge Rule - Cleanup Old Orders (runs daily at midnight UTC)
resource "aws_cloudwatch_event_rule" "cleanup_old_orders" {
  name                = "${var.project_name}-cleanup-old-orders"
  description         = "Cleanup expired orders at midnight UTC daily"
  schedule_expression = "cron(0 0 * * ? *)" # Midnight UTC

  tags = {
    Name        = "${var.project_name}-cleanup-rule"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Create a simple Lambda function for testing EventBridge triggers
resource "aws_lambda_function" "eventbridge_handler" {
  filename         = "${path.module}/lambda/eventbridge_handler.zip"
  function_name    = "${var.project_name}-eventbridge-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/eventbridge_handler.zip")
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      REGION       = var.aws_region
      PROJECT_NAME = var.project_name
      ENVIRONMENT  = var.environment
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.project_name}-eventbridge-handler"
    Project     = var.project_name
    Environment = var.environment
  }
}

# EventBridge Target - Daily Sales Report triggers Lambda
resource "aws_cloudwatch_event_target" "daily_sales_target" {
  rule      = aws_cloudwatch_event_rule.daily_sales_report.name
  target_id = "DailySalesLambda"
  arn       = aws_lambda_function.eventbridge_handler.arn

  input = jsonencode({
    event_type = "daily_sales_report"
    message    = "Generate daily sales report"
  })
}

# EventBridge Target - Weekly Newsletter triggers Lambda
resource "aws_cloudwatch_event_target" "weekly_newsletter_target" {
  rule      = aws_cloudwatch_event_rule.weekly_newsletter.name
  target_id = "WeeklyNewsletterLambda"
  arn       = aws_lambda_function.eventbridge_handler.arn

  input = jsonencode({
    event_type = "weekly_newsletter"
    message    = "Send weekly newsletter to subscribers"
  })
}

# EventBridge Target - Flash Sale triggers SNS
resource "aws_cloudwatch_event_target" "flash_sale_target" {
  rule      = aws_cloudwatch_event_rule.flash_sale_reminder.name
  target_id = "FlashSaleSNS"
  arn       = aws_sns_topic.order_notifications.arn

  input_transformer {
    input_paths = {
      time = "$.time"
    }
    input_template = "\"Flash Sale Alert: Check ELLORE for limited-time offers! Triggered at <time>\""
  }
}

# EventBridge Target - Cleanup triggers Lambda
resource "aws_cloudwatch_event_target" "cleanup_target" {
  rule      = aws_cloudwatch_event_rule.cleanup_old_orders.name
  target_id = "CleanupLambda"
  arn       = aws_lambda_function.eventbridge_handler.arn

  input = jsonencode({
    event_type = "cleanup_old_orders"
    message    = "Cleanup expired orders from DynamoDB"
  })
}

# Lambda Permission - Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eventbridge_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${var.project_name}-*"
}

# SNS Permission - Allow EventBridge to publish to SNS
resource "aws_sns_topic_policy" "eventbridge_publish" {
  arn = aws_sns_topic.order_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.order_notifications.arn
      }
    ]
  })
}

# CloudWatch Log Group for EventBridge handler
resource "aws_cloudwatch_log_group" "eventbridge_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.eventbridge_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-eventbridge-handler-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}