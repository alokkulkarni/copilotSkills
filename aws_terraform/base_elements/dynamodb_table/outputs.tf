# ============================================
# Outputs for DynamoDB Table Module
# ============================================

# ------------------
# Table Outputs
# ------------------

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_stream_arn" {
  description = "ARN of the DynamoDB table stream"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "table_stream_label" {
  description = "Timestamp of when the stream was enabled"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null
}

output "table_hash_key" {
  description = "Hash key of the table"
  value       = aws_dynamodb_table.this.hash_key
}

output "table_range_key" {
  description = "Range key of the table"
  value       = aws_dynamodb_table.this.range_key
}

# ------------------
# IAM Outputs
# ------------------

output "lambda_access_policy_arn" {
  description = "ARN of the Lambda access policy"
  value       = var.create_lambda_access_policy ? aws_iam_policy.lambda_dynamodb_access[0].arn : null
}

output "lambda_access_policy_name" {
  description = "Name of the Lambda access policy"
  value       = var.create_lambda_access_policy ? aws_iam_policy.lambda_dynamodb_access[0].name : null
}

output "read_only_policy_arn" {
  description = "ARN of the read-only access policy"
  value       = var.create_read_only_policy ? aws_iam_policy.dynamodb_read_only[0].arn : null
}

output "write_only_policy_arn" {
  description = "ARN of the write-only access policy"
  value       = var.create_write_only_policy ? aws_iam_policy.dynamodb_write_only[0].arn : null
}

output "custom_policy_arn" {
  description = "ARN of the custom IAM policy"
  value       = var.custom_iam_policy != null ? aws_iam_policy.custom[0].arn : null
}

# ------------------
# Auto-Scaling Outputs
# ------------------

output "autoscaling_read_target_id" {
  description = "Resource ID of the read capacity auto-scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_target.table_read[0].id : null
}

output "autoscaling_write_target_id" {
  description = "Resource ID of the write capacity auto-scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_target.table_write[0].id : null
}

output "autoscaling_read_policy_name" {
  description = "Name of the read capacity auto-scaling policy"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_policy.table_read[0].name : null
}

output "autoscaling_write_policy_name" {
  description = "Name of the write capacity auto-scaling policy"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? aws_appautoscaling_policy.table_write[0].name : null
}

# ------------------
# Backup Outputs
# ------------------

output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = var.enable_backup_vault ? aws_backup_vault.dynamodb[0].arn : null
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = var.enable_backup_vault ? aws_backup_vault.dynamodb[0].name : null
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = var.enable_backup_plan ? aws_backup_plan.dynamodb[0].id : null
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = var.enable_backup_plan ? aws_backup_plan.dynamodb[0].arn : null
}

output "backup_selection_id" {
  description = "ID of the backup selection"
  value       = var.enable_backup_plan ? aws_backup_selection.dynamodb[0].id : null
}

# ------------------
# Stream Outputs
# ------------------

output "stream_lambda_mappings" {
  description = "Map of Lambda event source mapping IDs"
  value = var.stream_enabled && var.enable_stream_lambda_triggers ? {
    for k, v in aws_lambda_event_source_mapping.dynamodb_stream : k => v.id
  } : {}
}

output "stream_log_group_name" {
  description = "Name of the CloudWatch log group for stream processing"
  value       = var.stream_enabled && var.create_stream_log_group ? aws_cloudwatch_log_group.stream_processing[0].name : null
}

output "stream_log_group_arn" {
  description = "ARN of the CloudWatch log group for stream processing"
  value       = var.stream_enabled && var.create_stream_log_group ? aws_cloudwatch_log_group.stream_processing[0].arn : null
}

output "kinesis_destination_status" {
  description = "Status of the Kinesis streaming destination"
  value       = var.stream_enabled && var.enable_kinesis_destination ? aws_dynamodb_kinesis_streaming_destination.this[0].id : null
}

# ------------------
# Global Table Outputs
# ------------------

output "replica_regions" {
  description = "List of replica regions for global table"
  value       = [for replica in var.replica_regions : replica.region_name]
}

# ------------------
# Additional Metadata
# ------------------

output "table_billing_mode" {
  description = "Billing mode of the table"
  value       = aws_dynamodb_table.this.billing_mode
}

output "table_deletion_protection" {
  description = "Whether deletion protection is enabled"
  value       = aws_dynamodb_table.this.deletion_protection_enabled
}

output "table_point_in_time_recovery" {
  description = "Whether point-in-time recovery is enabled"
  value       = aws_dynamodb_table.this.point_in_time_recovery[0].enabled
}
