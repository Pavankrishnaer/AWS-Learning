# SES Email Identity - Sender Email Address
# Note: You need to verify this email address in SES before it can send emails
resource "aws_ses_email_identity" "sender" {
  email = "pavankrishnaer@gmail.com" # CHANGE THIS to an email you control
}

# SES Configuration Set for tracking
resource "aws_ses_configuration_set" "ellore_emails" {
  name = "${var.project_name}-email-config"
}

# CloudWatch Event Destination for SES metrics
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.ellore_emails.name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "ses:configuration-set"
    value_source   = "messageTag"
  }
}