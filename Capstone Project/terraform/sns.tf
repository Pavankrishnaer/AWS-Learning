# SNS Topic - Order Notifications
resource "aws_sns_topic" "order_notifications" {
  name = "${var.project_name}-order-notifications"

  tags = {
    Name        = "${var.project_name}-order-notifications-topic"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SNS Topic - System Alerts
resource "aws_sns_topic" "system_alerts" {
  name = "${var.project_name}-system-alerts"

  tags = {
    Name        = "${var.project_name}-system-alerts-topic"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SNS Email Subscription for Order Notifications (update with your email)
resource "aws_sns_topic_subscription" "order_notifications_email" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = "pavankrishnaer@gmail.com" # CHANGE THIS to your actual email
}