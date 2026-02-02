# ============================================
# CloudWatch Log Group for Contact Flows
# ============================================
# Create dedicated log group for contact flow logs with configurable retention
# This helps with debugging contact flow issues and tracking call flows

resource "aws_cloudwatch_log_group" "contact_flow_logs" {
  count = var.contact_flow_logs_enabled ? 1 : 0

  name              = "/aws/connect/${var.instance_alias}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
