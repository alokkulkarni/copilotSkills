# ============================================
# Lambda Layer Outputs
# ============================================

output "layer_arn" {
  description = "ARN of the Lambda layer"
  value       = module.python_dependencies_layer.layer_arn
}

output "layer_version" {
  description = "Version of the Lambda layer"
  value       = module.python_dependencies_layer.layer_version
}

# ============================================
# Lambda Function Outputs
# ============================================

output "data_processor_function_arn" {
  description = "ARN of the data processor Lambda function"
  value       = module.data_processor_function.function_arn
}

output "data_processor_function_name" {
  description = "Name of the data processor Lambda function"
  value       = module.data_processor_function.function_name
}

output "data_processor_log_group" {
  description = "CloudWatch Log Group for data processor function"
  value       = module.data_processor_function.log_group_name
}

# ============================================
# API Function Outputs
# ============================================

output "api_function_url" {
  description = "HTTP URL for the API function"
  value       = module.api_function.function_url
}

output "api_function_arn" {
  description = "ARN of the API Lambda function"
  value       = module.api_function.function_arn
}

# ============================================
# Test Commands
# ============================================

output "test_commands" {
  description = "Commands to test the Lambda functions"
  value = <<-EOT
    # Test data processor function
    aws lambda invoke \\
      --function-name ${module.data_processor_function.function_name} \\
      --payload '{"action":"process","data":"test"}' \\
      --region ${var.aws_region} \\
      response.json && cat response.json

    # Test API function via Function URL
    curl ${module.api_function.function_url}
  EOT
}
