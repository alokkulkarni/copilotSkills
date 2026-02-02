# ================================
# IAM Role for Lex Bot
# ================================

resource "aws_iam_role" "lex_bot" {
  count = var.create_role ? 1 : 0

  name        = "${var.bot_name}-role"
  description = "IAM role for Lex bot ${var.bot_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lex_bot_basic" {
  count = var.create_role ? 1 : 0

  name = "${var.bot_name}-basic-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "polly:SynthesizeSpeech",
          "comprehend:DetectSentiment"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Logs policy for Lex bot
# Note: Resource ARN uses wildcard for region (*) to support multi-region deployments
# Ensure IAM permissions are granted for the target deployment region (e.g., eu-west-2)
resource "aws_iam_role_policy" "lex_bot_cloudwatch" {
  count = var.create_role && var.attach_cloudwatch_policy ? 1 : 0

  name = "${var.bot_name}-cloudwatch-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lex/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lex_bot_s3" {
  count = var.create_role && var.attach_s3_policy ? 1 : 0

  name = "${var.bot_name}-s3-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = var.s3_bucket_arn != null ? "${var.s3_bucket_arn}/*" : "*"
      }
    ]
  })
}

# ================================
# Data Sources
# ================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
