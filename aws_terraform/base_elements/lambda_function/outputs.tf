# ============================================
# Lambda Function Outputs
# ============================================

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function (includes version)"
  value       = aws_lambda_function.this.qualified_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "function_last_modified" {
  description = "Date the Lambda function was last modified"
  value       = aws_lambda_function.this.last_modified
}

output "function_invoke_arn" {
  description = "ARN to use for invoking the Lambda function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_source_code_size" {
  description = "Size of the function deployment package in bytes"
  value       = aws_lambda_function.this.source_code_size
}

output "function_code_sha256" {
  description = "Base64-encoded SHA256 hash of the function package"
  value       = aws_lambda_function.this.source_code_hash
}

output "function_signing_job_arn" {
  description = "ARN of the signing job (if code signing is enabled)"
  value       = aws_lambda_function.this.signing_job_arn
}

output "function_signing_profile_version_arn" {
  description = "ARN of the signing profile version (if code signing is enabled)"
  value       = aws_lambda_function.this.signing_profile_version_arn
}

# ============================================
# IAM Role Outputs
# ============================================

output "role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.lambda_role[0].arn : var.lambda_role_arn
}

output "role_name" {
  description = "Name of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.lambda_role[0].name : null
}

output "role_id" {
  description = "ID of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.lambda_role[0].id : null
}

# ============================================
# CloudWatch Log Group Outputs
# ============================================

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = var.create_log_group ? aws_cloudwatch_log_group.lambda_log_group[0].name : "/aws/lambda/${var.function_name}"
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for the Lambda function"
  value       = var.create_log_group ? aws_cloudwatch_log_group.lambda_log_group[0].arn : null
}

# ============================================
# Function URL Outputs
# ============================================

output "function_url" {
  description = "URL endpoint for the Lambda function (if Function URL is enabled)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}

output "function_url_id" {
  description = "ID of the Function URL configuration"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].url_id : null
}

# ============================================
# Lambda Alias Outputs
# ============================================

output "alias_arn" {
  description = "ARN of the Lambda function alias"
  value       = var.create_alias ? aws_lambda_alias.this[0].arn : null
}

output "alias_name" {
  description = "Name of the Lambda function alias"
  value       = var.create_alias ? aws_lambda_alias.this[0].name : null
}

output "alias_invoke_arn" {
  description = "ARN to use for invoking the Lambda function alias from API Gateway"
  value       = var.create_alias ? aws_lambda_alias.this[0].invoke_arn : null
}

# ============================================
# Snap Start Outputs
# ============================================

output "snap_start_optimization_status" {
  description = "Snap Start optimization status (for Java functions)"
  value       = aws_lambda_function.this.snap_start
}
