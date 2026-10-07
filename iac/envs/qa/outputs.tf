output "api_gateway_url" {
  value = module.image_processor.api_gateway_url
}
output "bucket_name" {
  value = module.image_processor.bucket_name
}
output "upload_lambda_name" {
  value = module.image_processor.upload_lambda_name
}
output "crop_lambda_name" {
  value = module.image_processor.crop_lambda_name
}
output "main_queue_url" {
  value = module.image_processor.main_queue_url
}
output "dlq_url" {
  value = module.image_processor.dlq_url
}
output "environment" {
  value = module.image_processor.environment
}
output "region" {
  value = module.image_processor.region
}
output "account_id" {
  value = module.image_processor.account_id
}
