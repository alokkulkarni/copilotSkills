# ============================================
# Lambda Layer Outputs
# ============================================

output "layer_arn" {
  description = "ARN of the Lambda layer version (use this to attach to Lambda functions)"
  value       = aws_lambda_layer_version.this.arn
}

output "layer_version" {
  description = "Version number of the Lambda layer"
  value       = aws_lambda_layer_version.this.version
}

output "layer_name" {
  description = "Name of the Lambda layer"
  value       = aws_lambda_layer_version.this.layer_name
}

output "created_date" {
  description = "Date the layer version was created"
  value       = aws_lambda_layer_version.this.created_date
}

output "source_code_size" {
  description = "Size of the layer code in bytes"
  value       = aws_lambda_layer_version.this.source_code_size
}

output "compatible_runtimes" {
  description = "List of compatible runtimes for this layer"
  value       = aws_lambda_layer_version.this.compatible_runtimes
}

output "signing_profile_version_arn" {
  description = "ARN of the signing profile version (if code signing is enabled)"
  value       = aws_lambda_layer_version.this.signing_profile_version_arn
}

output "signing_job_arn" {
  description = "ARN of the signing job (if code signing is enabled)"
  value       = aws_lambda_layer_version.this.signing_job_arn
}
