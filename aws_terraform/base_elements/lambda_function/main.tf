# ============================================
# IAM Role for Lambda Function
# ============================================

resource "aws_iam_role" "lambda_role" {
  count = var.create_role ? 1 : 0

  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
  description        = "IAM role for Lambda function ${var.function_name}"

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-role"
    }
  )
}

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policy for basic Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count = var.create_role && var.attach_cloudwatch_logs_policy ? 1 : 0

  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC execution policy if function is in VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count = var.create_role && var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach custom policies
resource "aws_iam_role_policy_attachment" "lambda_custom_policies" {
  count = var.create_role ? length(var.attach_policy_arns) : 0

  role       = aws_iam_role.lambda_role[0].name
  policy_arn = var.attach_policy_arns[count.index]
}

# Inline policy for Lambda function
resource "aws_iam_role_policy" "lambda_inline_policy" {
  count = var.create_role && var.inline_policy != null ? 1 : 0

  name   = "${var.function_name}-inline-policy"
  role   = aws_iam_role.lambda_role[0].id
  policy = var.inline_policy
}

# ============================================
# Lambda Function
# ============================================

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

# ============================================
# CloudWatch Log Group
# ============================================

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-logs"
    }
  )
}

# ============================================
# Lambda Function URL (Optional)
# ============================================

resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors_config != null ? [var.function_url_cors_config] : []
    content {
      allow_credentials = lookup(cors.value, "allow_credentials", null)
      allow_headers     = lookup(cors.value, "allow_headers", null)
      allow_methods     = lookup(cors.value, "allow_methods", null)
      allow_origins     = lookup(cors.value, "allow_origins", null)
      expose_headers    = lookup(cors.value, "expose_headers", null)
      max_age           = lookup(cors.value, "max_age", null)
    }
  }
}

# ============================================
# Lambda Permission for Function URL
# ============================================

resource "aws_lambda_permission" "function_url" {
  count = var.create_function_url && var.function_url_auth_type == "NONE" ? 1 : 0

  statement_id           = "AllowPublicFunctionURL"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# ============================================
# Lambda Alias (Optional)
# ============================================

resource "aws_lambda_alias" "this" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.this.function_name
  function_version = var.alias_function_version

  dynamic "routing_config" {
    for_each = var.alias_routing_config != null ? [var.alias_routing_config] : []
    content {
      additional_version_weights = routing_config.value.additional_version_weights
    }
  }
}
