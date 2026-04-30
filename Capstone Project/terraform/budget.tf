# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "${var.project_name}-budget-alerts"

  tags = {
    Name        = "${var.project_name}-budget-alerts"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SNS Topic Subscription (replace with your email)
resource "aws_sns_topic_subscription" "budget_email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = "pavankrishnaer@gmail.com" # REPLACE THIS WITH YOUR ACTUAL EMAIL
}

# AWS Budget
resource "aws_budgets_budget" "monthly_budget" {
  name              = "${var.project_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "50"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-04-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["pavankrishnaer@gmail.com"] # REPLACE THIS WITH YOUR ACTUAL EMAIL
  }

  tags = {
    Name        = "${var.project_name}-monthly-budget"
    Project     = var.project_name
    Environment = var.environment
  }
}