resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.upload.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.crop.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/image-processor-api-${var.environment}"
  retention_in_days = 14
}

resource "aws_sns_topic" "dlq_alarms" {
  name = "image-processor-dlq-alarms-${var.environment}"
}

resource "aws_cloudwatch_metric_alarm" "dlq_visible_messages" {
  alarm_name          = "dlq-messages-alarm-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when messages are visible in the DLQ"

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  alarm_actions = [aws_sns_topic.dlq_alarms.arn]
}
