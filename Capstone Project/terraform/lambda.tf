# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM Policy for Lambda - DynamoDB Access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "${var.project_name}-lambda-dynamodb-policy"
  description = "Allow Lambda functions to access DynamoDB tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.contacts.arn,
          aws_dynamodb_table.orders.arn,
          aws_dynamodb_table.newsletter.arn,
          "${aws_dynamodb_table.contacts.arn}/index/*",
          "${aws_dynamodb_table.orders.arn}/index/*",
          "${aws_dynamodb_table.newsletter.arn}/index/*"
        ]
      }
    ]
  })
}

# IAM Policy for Lambda - SSM Parameter Store Access
resource "aws_iam_policy" "lambda_ssm_policy" {
  name        = "${var.project_name}-lambda-ssm-policy"
  description = "Allow Lambda functions to read SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# IAM Policy for Lambda - CloudWatch Logs
resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "${var.project_name}-lambda-logs-policy"
  description = "Allow Lambda functions to write CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-*"
      }
    ]
  })
}

# Attach policies to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
}

# Lambda Function - Contact Handler
resource "aws_lambda_function" "contact_handler" {
  filename         = "${path.module}/lambda/contact_handler.zip"
  function_name    = "${var.project_name}-contact-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/contact_handler.zip")
  runtime          = "python3.12"
  timeout          = 30
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
    Name        = "${var.project_name}-contact-handler"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Lambda Function - Order Handler
resource "aws_lambda_function" "order_handler" {
  filename         = "${path.module}/lambda/order_handler.zip"
  function_name    = "${var.project_name}-order-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/order_handler.zip")
  runtime          = "python3.12"
  timeout          = 30
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
    Name        = "${var.project_name}-order-handler"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Lambda Function - Newsletter Handler
resource "aws_lambda_function" "newsletter_handler" {
  filename         = "${path.module}/lambda/newsletter_handler.zip"
  function_name    = "${var.project_name}-newsletter-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/newsletter_handler.zip")
  runtime          = "python3.12"
  timeout          = 30
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
    Name        = "${var.project_name}-newsletter-handler"
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "contact_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.contact_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-contact-handler-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "order_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.order_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-order-handler-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "newsletter_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.newsletter_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-newsletter-handler-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM Policy for Lambda - SES Send Email
resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "${var.project_name}-lambda-ses-policy"
  description = "Allow Lambda functions to send emails via SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach SES policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ses_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}

# IAM Policy for Lambda - SQS Access
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "${var.project_name}-lambda-sqs-policy"
  description = "Allow Lambda functions to send messages to SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.order_processing.arn,
          aws_sqs_queue.order_processing_fifo.arn
        ]
      }
    ]
  })
}

# IAM Policy for Lambda - SNS Publish
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "${var.project_name}-lambda-sns-policy"
  description = "Allow Lambda functions to publish to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          aws_sns_topic.order_notifications.arn,
          aws_sns_topic.system_alerts.arn
        ]
      }
    ]
  })
}

# Attach SQS policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_sqs_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# Attach SNS policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# IAM Policy for Lambda - AWS Translate
resource "aws_iam_policy" "lambda_translate_policy" {
  name        = "${var.project_name}-lambda-translate-policy"
  description = "Allow Lambda functions to use AWS Translate"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "translate:TranslateText",
          "translate:ListLanguages"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Translate policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_translate_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_translate_policy.arn
}

# Lambda Function - Translation Handler
resource "aws_lambda_function" "translate_handler" {
  filename         = "${path.module}/lambda/translate_handler.zip"
  function_name    = "${var.project_name}-translate-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/translate_handler.zip")
  runtime          = "python3.12"
  timeout          = 30
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
    Name        = "${var.project_name}-translate-handler"
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Log Group for Translate handler
resource "aws_cloudwatch_log_group" "translate_handler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.translate_handler.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-translate-handler-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Update Lambda execution role for X-Ray
resource "aws_iam_role_policy_attachment" "lambda_xray_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}