# ============================================
# Lambda Function
# ============================================
# Core Lambda function resource
# Related components are in separate files:
# - iam.tf: IAM roles and policies
# - logging.tf: CloudWatch log groups
# - function_url.tf: Lambda function URLs
# - alias.tf: Lambda aliases

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = var.create_role ? aws_iam_role.lambda_role[0].arn : var.lambda_role_arn

  # Code deployment
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version
  source_code_hash = var.source_code_hash

  # Runtime configuration
  handler                        = var.handler
  runtime                        = var.runtime
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish

  # Lambda layers
  layers = var.layers

  # Environment variables
  dynamic "environment" {
    for_each = var.environment_variables != null ? [var.environment_variables] : []
    content {
      variables = environment.value
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Tracing configuration
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # Ephemeral storage
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  # File system configuration
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Image configuration (for container images)
  dynamic "image_config" {
    for_each = var.image_config != null ? [var.image_config] : []
    content {
      command           = lookup(image_config.value, "command", null)
      entry_point       = lookup(image_config.value, "entry_point", null)
      working_directory = lookup(image_config.value, "working_directory", null)
    }
  }

  # Architectures
  architectures = var.architectures

  # Code signing
  code_signing_config_arn = var.code_signing_config_arn

  # Snap Start configuration (for Java)
  dynamic "snap_start" {
    for_each = var.snap_start_apply_on != null ? [1] : []
    content {
      apply_on = var.snap_start_apply_on
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_execution,
    aws_iam_role_policy_attachment.lambda_custom_policies
  ]
}
