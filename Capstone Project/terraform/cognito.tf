# ═══════════════════════════════════════════════════════════════
# Amazon Cognito - User Authentication and Authorization
# ═══════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# Cognito User Pool
# ─────────────────────────────────────────────

resource "aws_cognito_user_pool" "customers" {
  name = "${var.project_name}-customers"

  # Username configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Verification message template
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "ELLORE - Verify your email address"
    email_message        = "Welcome to ELLORE! Your verification code is {####}"
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false

    string_attribute_constraints {
      min_length = 5
      max_length = 255
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 255
    }
  }

  # Additional settings
  mfa_configuration = "OFF"

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  tags = {
    Name        = "${var.project_name}-user-pool"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────
# Cognito User Pool Client (Web App)
# ─────────────────────────────────────────────

resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.project_name}-web-client"
  user_pool_id = aws_cognito_user_pool.customers.id

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  # Token validity
  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name"
  ]

  write_attributes = [
    "email",
    "name"
  ]
}

# ─────────────────────────────────────────────
# API Gateway Cognito Authorizer
# ─────────────────────────────────────────────

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.project_name}-cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.customers.arn]

  identity_source = "method.request.header.Authorization"
}

# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.customers.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.customers.arn
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool Endpoint"
  value       = aws_cognito_user_pool.customers.endpoint
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID (for frontend)"
  value       = aws_cognito_user_pool_client.web_client.id
}

output "cognito_region" {
  description = "AWS region for Cognito (for frontend)"
  value       = var.aws_region
}
