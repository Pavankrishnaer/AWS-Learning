# Security Group for Lambda Functions
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda functions in VPC"
  vpc_id      = aws_vpc.ellore_vpc.id

  tags = {
    Name        = "${var.project_name}-lambda-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Lambda SG - Egress Rule: Allow HTTPS to AWS APIs
resource "aws_vpc_security_group_egress_rule" "lambda_sg_https_outbound" {
  security_group_id = aws_security_group.lambda_sg.id
  description       = "Allow outbound HTTPS to AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Lambda SG - Egress Rule: Allow HTTP (for package downloads)
resource "aws_vpc_security_group_egress_rule" "lambda_sg_http_outbound" {
  security_group_id = aws_security_group.lambda_sg.id
  description       = "Allow outbound HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Security Group for VPC Endpoints (future use)
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.ellore_vpc.id

  tags = {
    Name        = "${var.project_name}-endpoint-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# VPC Endpoint SG - Ingress Rule: Allow HTTPS from Lambda SG
resource "aws_vpc_security_group_ingress_rule" "endpoint_sg_https_from_lambda" {
  security_group_id            = aws_security_group.vpc_endpoint_sg.id
  description                  = "Allow HTTPS from Lambda functions"
  referenced_security_group_id = aws_security_group.lambda_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# VPC Endpoint SG - Egress Rule: Allow all outbound
resource "aws_vpc_security_group_egress_rule" "endpoint_sg_all_outbound" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}