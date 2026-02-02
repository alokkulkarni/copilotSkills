# ============================================
# DynamoDB Streams Configuration
# ============================================

# Lambda event source mapping for DynamoDB streams
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  for_each = var.stream_enabled && var.enable_stream_lambda_triggers ? var.stream_lambda_functions : {}

  event_source_arn  = aws_dynamodb_table.this.stream_arn
  function_name     = each.value.function_name
  starting_position = each.value.starting_position
  batch_size        = lookup(each.value, "batch_size", 100)
  maximum_batching_window_in_seconds = lookup(each.value, "maximum_batching_window_in_seconds", 0)
  parallelization_factor = lookup(each.value, "parallelization_factor", 1)
  maximum_retry_attempts = lookup(each.value, "maximum_retry_attempts", -1)
  maximum_record_age_in_seconds = lookup(each.value, "maximum_record_age_in_seconds", -1)
  bisect_batch_on_function_error = lookup(each.value, "bisect_batch_on_function_error", false)
  enabled = lookup(each.value, "enabled", true)

  dynamic "destination_config" {
    for_each = lookup(each.value, "on_failure_destination", null) != null ? [1] : []
    content {
      on_failure {
        destination_arn = each.value.on_failure_destination
      }
    }
  }

  dynamic "filter_criteria" {
    for_each = lookup(each.value, "filter_pattern", null) != null ? [1] : []
    content {
      filter {
        pattern = each.value.filter_pattern
      }
    }
  }

  depends_on = [aws_dynamodb_table.this]
}

# CloudWatch log group for stream processing monitoring
resource "aws_cloudwatch_log_group" "stream_processing" {
  count = var.stream_enabled && var.create_stream_log_group ? 1 : 0

  name              = "/aws/dynamodb/streams/${var.table_name}"
  retention_in_days = var.stream_log_retention_days
  kms_key_id        = var.log_kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.table_name}-stream-logs"
    }
  )
}

# Kinesis Data Streams for DynamoDB (alternative to Lambda)
resource "aws_dynamodb_kinesis_streaming_destination" "this" {
  count = var.stream_enabled && var.enable_kinesis_destination ? 1 : 0

  stream_arn = var.kinesis_stream_arn
  table_name = aws_dynamodb_table.this.name
}
