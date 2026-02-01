# ============================================
# AWS Lambda Layer Resource
# ============================================
# Creates a Lambda layer that can be attached to Lambda functions
# Supports multiple runtimes and automatic versioning

resource "aws_lambda_layer_version" "this" {
  layer_name          = var.layer_name
  description         = var.description
  filename            = var.filename
  s3_bucket           = var.s3_bucket
  s3_key              = var.s3_key
  s3_object_version   = var.s3_object_version
  source_code_hash    = var.source_code_hash
  compatible_runtimes = var.compatible_runtimes
  license_info        = var.license_info

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# Lambda Layer Permission (Optional)
# ============================================
# Allows other AWS accounts or organizations to use this layer

resource "aws_lambda_layer_version_permission" "this" {
  count = var.enable_layer_permissions ? 1 : 0

  layer_name     = aws_lambda_layer_version.this.layer_name
  version_number = aws_lambda_layer_version.this.version
  action         = var.permission_action
  principal      = var.permission_principal
  organization_id = var.organization_id
  statement_id   = var.permission_statement_id
}
