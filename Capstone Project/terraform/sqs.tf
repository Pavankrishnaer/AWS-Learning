# SQS Standard Queue - Order Processing
resource "aws_sqs_queue" "order_processing" {
  name                       = "${var.project_name}-order-processing"
  visibility_timeout_seconds = 300    # 5 minutes for Lambda processing
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 10     # Long polling

  tags = {
    Name        = "${var.project_name}-order-processing-queue"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SQS FIFO Queue - Order Processing (guaranteed ordering)
resource "aws_sqs_queue" "order_processing_fifo" {
  name                        = "${var.project_name}-order-processing.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 300
  message_retention_seconds   = 345600

  tags = {
    Name        = "${var.project_name}-order-processing-fifo-queue"
    Project     = var.project_name
    Environment = var.environment
  }
}

# SQS Dead Letter Queue - Failed Messages
resource "aws_sqs_queue" "order_processing_dlq" {
  name                      = "${var.project_name}-order-processing-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.project_name}-order-dlq"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Redrive Policy - Send failed messages to DLQ after 3 attempts
resource "aws_sqs_queue_redrive_policy" "order_processing" {
  queue_url = aws_sqs_queue.order_processing.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_processing_dlq.arn
    maxReceiveCount     = 3
  })
}