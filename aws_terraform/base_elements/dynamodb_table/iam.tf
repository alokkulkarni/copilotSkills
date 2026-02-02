# ============================================
# IAM Policies for DynamoDB Access
# ============================================

# Data sources for existing Lambda functions
data "aws_lambda_function" "existing" {
  for_each = var.lambda_function_names

  function_name = each.value
}

# IAM policy for Lambda to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_access" {
  count = var.create_lambda_access_policy ? 1 : 0

  name        = "${var.table_name}-lambda-access"
  description = "IAM policy for Lambda functions to access DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem"
        ]
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      },
      # Streams access
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = var.stream_enabled ? "${aws_dynamodb_table.this.arn}/stream/*" : aws_dynamodb_table.this.arn
        Condition = var.stream_enabled ? {} : null
      }
    ]
  })

  tags = var.tags
}

# Attach policy to Lambda function roles
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  for_each = var.create_lambda_access_policy ? var.lambda_function_names : []

  role       = data.aws_lambda_function.existing[each.key].role
  policy_arn = aws_iam_policy.lambda_dynamodb_access[0].arn
}

# IAM policy for read-only access
resource "aws_iam_policy" "dynamodb_read_only" {
  count = var.create_read_only_policy ? 1 : 0

  name        = "${var.table_name}-read-only"
  description = "Read-only access to DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      }
    ]
  })

  tags = var.tags
}

# IAM policy for write-only access
resource "aws_iam_policy" "dynamodb_write_only" {
  count = var.create_write_only_policy ? 1 : 0

  name        = "${var.table_name}-write-only"
  description = "Write-only access to DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.this.arn
      }
    ]
  })

  tags = var.tags
}

# Custom IAM policy (user-provided)
resource "aws_iam_policy" "custom" {
  count = var.custom_iam_policy != null ? 1 : 0

  name        = "${var.table_name}-custom-policy"
  description = "Custom IAM policy for DynamoDB table ${var.table_name}"
  policy      = var.custom_iam_policy

  tags = var.tags
}
