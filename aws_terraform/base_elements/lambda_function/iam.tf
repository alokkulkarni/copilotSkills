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
