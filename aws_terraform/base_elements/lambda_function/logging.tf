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
