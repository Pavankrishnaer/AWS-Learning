# ═══════════════════════════════════════════════════════════════
# Amazon Route 53 - DNS Management
# ═══════════════════════════════════════════════════════════════
# NOTE: This configuration assumes you own a domain.
# If you don't have a domain, comment out this file and skip Route 53.
# The CloudFront URL will continue to work without a custom domain.

# ─────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────
# Update this variable with your actual domain name
# If you don't have a domain, set this to null and comment out the resources below

variable "domain_name" {
  description = "Custom domain name for the website (leave empty if not using custom domain)"
  type        = string
  default     = "" # Set to your domain like "ellore-fashion.com" or leave empty
}

# ─────────────────────────────────────────────
# Route 53 Hosted Zone
# ─────────────────────────────────────────────
# Only create if domain_name is provided

resource "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-hosted-zone"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────
# DNS Record - Root Domain (example.com)
# ─────────────────────────────────────────────

resource "aws_route53_record" "root" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# ─────────────────────────────────────────────
# DNS Record - WWW Subdomain (www.example.com)
# ─────────────────────────────────────────────

resource "aws_route53_record" "www" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# ─────────────────────────────────────────────
# Health Check for Website Monitoring
# ─────────────────────────────────────────────

resource "aws_route53_health_check" "website" {
  count             = var.domain_name != "" ? 1 : 0
  fqdn              = aws_cloudfront_distribution.website.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/index.html"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name        = "${var.project_name}-health-check"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────
# CloudWatch Alarm for Health Check
# ─────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "health_check" {
  count               = var.domain_name != "" ? 1 : 0
  alarm_name          = "${var.project_name}-website-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Alert when website health check fails"
  alarm_actions       = [aws_sns_topic.system_alerts.arn]

  dimensions = {
    HealthCheckId = aws_route53_health_check.website[0].id
  }
}

# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────

output "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].zone_id : "N/A - No domain configured"
}

output "route53_name_servers" {
  description = "Route 53 Name Servers (update these in your domain registrar)"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].name_servers : ["N/A - No domain configured"]
}

output "website_url_custom_domain" {
  description = "Website URL with custom domain"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "N/A - Using CloudFront URL"
}

# ═══════════════════════════════════════════════════════════════
# IMPORTANT SETUP INSTRUCTIONS
# ═══════════════════════════════════════════════════════════════
# 
# IF YOU OWN A DOMAIN:
# 1. Set var.domain_name to your domain (e.g., "ellore-fashion.com")
# 2. Run: terraform apply
# 3. Note the name_servers output
# 4. Update your domain registrar's DNS settings with these name servers
# 5. Wait 24-48 hours for DNS propagation
# 6. Your website will be accessible at https://yourdomain.com
#
# IF YOU DON'T OWN A DOMAIN:
# 1. Leave var.domain_name as empty string ("")
# 2. The Route 53 resources won't be created
# 3. Continue using CloudFront URL: https://dxsv8r9onjdox.cloudfront.net
# 4. You can add a domain later without affecting the current setup
#
# ═══════════════════════════════════════════════════════════════
