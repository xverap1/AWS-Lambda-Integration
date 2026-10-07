output "api_gateway_url" {
  description = "URL del API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.main.id
}

output "upload_lambda_name" {
  description = "Nombre de la función Lambda de subida"
  value       = aws_lambda_function.upload.function_name
}

output "crop_lambda_name" {
  description = "Nombre de la función Lambda de recorte"
  value       = aws_lambda_function.crop.function_name
}

output "main_queue_url" {
  description = "URL de la cola SQS principal"
  value       = aws_sqs_queue.main.url
}

output "dlq_url" {
  description = "URL de la Dead-Letter Queue (DLQ)"
  value       = aws_sqs_queue.dlq.url
}

output "environment" {
  description = "Entorno desplegado"
  value       = var.environment
}

output "region" {
  description = "Región de despliegue"
  value       = var.region
}

output "account_id" {
  description = "ID de la cuenta de AWS"
  value       = data.aws_caller_identity.current.account_id
}
