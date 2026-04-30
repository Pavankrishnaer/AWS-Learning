# ═══════════════════════════════════════════════════════════════
# AWS Secrets Manager - Secure Secrets Storage
# ═══════════════════════════════════════════════════════════════
# Stores sensitive configuration with automatic rotation capability

# Secret: Admin Email Configuration
resource "aws_secretsmanager_secret" "admin_config" {
  name                    = "${var.project_name}/${var.environment}/admin/config"
  description             = "Admin configuration including email and notification preferences"
  recovery_window_in_days = 0 # Force delete immediately (no recovery)

  tags = {
    Name        = "${var.project_name}-admin-config"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "admin_config" {
  secret_id = aws_secretsmanager_secret.admin_config.id
  secret_string = jsonencode({
    email                = "pavankrishnaer@gmail.com"
    notification_enabled = true
    alert_threshold      = 100
  })
}

# Secret: API Keys (placeholder for future integrations)
resource "aws_secretsmanager_secret" "api_keys" {
  name                    = "${var.project_name}/${var.environment}/api/keys"
  description             = "External API keys for payment, shipping, etc."
  recovery_window_in_days = 0 # Force delete immediately (no recovery)

  tags = {
    Name        = "${var.project_name}-api-keys"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    stripe_key   = "placeholder_stripe_key"
    paypal_key   = "placeholder_paypal_key"
    shipping_api = "placeholder_shipping_key"
  })
}

# Secret: Database Configuration
resource "aws_secretsmanager_secret" "database_config" {
  name                    = "${var.project_name}/${var.environment}/database/config"
  description             = "Database connection details and credentials"
  recovery_window_in_days = 0 # Force delete immediately (no recovery)

  tags = {
    Name        = "${var.project_name}-database-config"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database_config" {
  secret_id = aws_secretsmanager_secret.database_config.id
  secret_string = jsonencode({
    contacts_table   = aws_dynamodb_table.contacts.name
    orders_table     = aws_dynamodb_table.orders.name
    newsletter_table = aws_dynamodb_table.newsletter.name
    region           = var.aws_region
  })
}

# ═══════════════════════════════════════════════════════════════
# IAM Policy for Lambda to Access Secrets
# ═══════════════════════════════════════════════════════════════

resource "aws_iam_policy" "lambda_secrets_policy" {
  name        = "${var.project_name}-lambda-secrets-policy"
  description = "Allow Lambda functions to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.admin_config.arn,
          aws_secretsmanager_secret.api_keys.arn,
          aws_secretsmanager_secret.database_config.arn
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-secrets-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Attach policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_secrets_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

# ═══════════════════════════════════════════════════════════════
# Outputs
# ═══════════════════════════════════════════════════════════════

output "secrets_admin_config_arn" {
  description = "ARN of admin config secret"
  value       = aws_secretsmanager_secret.admin_config.arn
  sensitive   = true
}

output "secrets_api_keys_arn" {
  description = "ARN of API keys secret"
  value       = aws_secretsmanager_secret.api_keys.arn
  sensitive   = true
}

output "secrets_database_config_arn" {
  description = "ARN of database config secret"
  value       = aws_secretsmanager_secret.database_config.arn
  sensitive   = true
}
