# API Gateway REST API
resource "aws_api_gateway_rest_api" "ellore_api" {
  name        = "${var.project_name}-api"
  description = "ELLORE E-Commerce Backend API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api"
    Project     = var.project_name
    Environment = var.environment
  }
}

# API Gateway Resource - /contact
resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  parent_id   = aws_api_gateway_rest_api.ellore_api.root_resource_id
  path_part   = "contact"
}

# API Gateway Resource - /order
resource "aws_api_gateway_resource" "order" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  parent_id   = aws_api_gateway_rest_api.ellore_api.root_resource_id
  path_part   = "order"
}

# API Gateway Resource - /newsletter
resource "aws_api_gateway_resource" "newsletter" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  parent_id   = aws_api_gateway_rest_api.ellore_api.root_resource_id
  path_part   = "newsletter"
}

# API Gateway Method - POST /contact
resource "aws_api_gateway_method" "contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method - POST /order
resource "aws_api_gateway_method" "order_post" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"                  # Require authentication
  authorizer_id = aws_api_gateway_authorizer.cognito.id # Use Cognito authorizer
}

# API Gateway Method - POST /newsletter
resource "aws_api_gateway_method" "newsletter_post" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.newsletter.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda Integration - /contact
resource "aws_api_gateway_integration" "contact_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ellore_api.id
  resource_id             = aws_api_gateway_resource.contact.id
  http_method             = aws_api_gateway_method.contact_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_handler.invoke_arn
}

# Lambda Integration - /order
resource "aws_api_gateway_integration" "order_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ellore_api.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.order_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_handler.invoke_arn
}

# Lambda Integration - /newsletter
resource "aws_api_gateway_integration" "newsletter_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ellore_api.id
  resource_id             = aws_api_gateway_resource.newsletter.id
  http_method             = aws_api_gateway_method.newsletter_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.newsletter_handler.invoke_arn
}

# Lambda Permission - Allow API Gateway to invoke contact handler
resource "aws_lambda_permission" "apigw_contact" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ellore_api.execution_arn}/*/*"
}

# Lambda Permission - Allow API Gateway to invoke order handler
resource "aws_lambda_permission" "apigw_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ellore_api.execution_arn}/*/*"
}

# Lambda Permission - Allow API Gateway to invoke newsletter handler
resource "aws_lambda_permission" "apigw_newsletter" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.newsletter_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ellore_api.execution_arn}/*/*"
}

# CORS - OPTIONS method for /contact
resource "aws_api_gateway_method" "contact_options" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = aws_api_gateway_method_response.contact_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# CORS - OPTIONS method for /order
resource "aws_api_gateway_method" "order_options" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "order_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.order_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "order_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.order_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "order_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.order_options.http_method
  status_code = aws_api_gateway_method_response.order_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# CORS - OPTIONS method for /newsletter
resource "aws_api_gateway_method" "newsletter_options" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.newsletter.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "newsletter_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.newsletter.id
  http_method = aws_api_gateway_method.newsletter_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "newsletter_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.newsletter.id
  http_method = aws_api_gateway_method.newsletter_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "newsletter_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.newsletter.id
  http_method = aws_api_gateway_method.newsletter_options.http_method
  status_code = aws_api_gateway_method_response.newsletter_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "ellore_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact.id,
      aws_api_gateway_method.contact_post.id,
      aws_api_gateway_integration.contact_lambda.id,
      aws_api_gateway_resource.order.id,
      aws_api_gateway_method.order_post.id,
      aws_api_gateway_integration.order_lambda.id,
      aws_api_gateway_resource.newsletter.id,
      aws_api_gateway_method.newsletter_post.id,
      aws_api_gateway_integration.newsletter_lambda.id,
      aws_api_gateway_resource.translate.id,
      aws_api_gateway_method.translate_post.id,
      aws_api_gateway_integration.translate_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.contact_lambda,
    aws_api_gateway_integration.order_lambda,
    aws_api_gateway_integration.newsletter_lambda,
    aws_api_gateway_integration.contact_options,
    aws_api_gateway_integration.order_options,
    aws_api_gateway_integration.newsletter_options
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.ellore_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  stage_name    = "prod"

  xray_tracing_enabled = true

  tags = {
    Name        = "${var.project_name}-api-prod-stage"
    Project     = var.project_name
    Environment = var.environment
  }
}

# API Gateway Resource - /translate
resource "aws_api_gateway_resource" "translate" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  parent_id   = aws_api_gateway_rest_api.ellore_api.root_resource_id
  path_part   = "translate"
}

# API Gateway Method - POST /translate
resource "aws_api_gateway_method" "translate_post" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.translate.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda Integration - /translate
resource "aws_api_gateway_integration" "translate_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ellore_api.id
  resource_id             = aws_api_gateway_resource.translate.id
  http_method             = aws_api_gateway_method.translate_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.translate_handler.invoke_arn
}

# Lambda Permission - Allow API Gateway to invoke translate handler
resource "aws_lambda_permission" "apigw_translate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translate_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ellore_api.execution_arn}/*/*"
}

# CORS - OPTIONS method for /translate
resource "aws_api_gateway_method" "translate_options" {
  rest_api_id   = aws_api_gateway_rest_api.ellore_api.id
  resource_id   = aws_api_gateway_resource.translate.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "translate_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.translate.id
  http_method = aws_api_gateway_method.translate_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "translate_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.translate.id
  http_method = aws_api_gateway_method.translate_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "translate_options" {
  rest_api_id = aws_api_gateway_rest_api.ellore_api.id
  resource_id = aws_api_gateway_resource.translate.id
  http_method = aws_api_gateway_method.translate_options.http_method
  status_code = aws_api_gateway_method_response.translate_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}