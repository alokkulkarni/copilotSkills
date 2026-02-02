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
