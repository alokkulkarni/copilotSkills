# ============================================
# DynamoDB Table Data Population
# ============================================
# Populate initial data into DynamoDB table
# Note: Use this for small seed data only
# For large datasets, use AWS CLI or SDK scripts

# Null resource to trigger data population script
resource "null_resource" "populate_data" {
  count = var.populate_initial_data && length(var.initial_data_items) > 0 ? 1 : 0

  # Trigger on table changes or data changes
  triggers = {
    table_id  = aws_dynamodb_table.this.id
    data_hash = md5(jsonencode(var.initial_data_items))
  }

  # Local-exec provisioner to populate data using AWS CLI
  provisioner "local-exec" {
    command = <<-EOT
      ${var.aws_cli_path} dynamodb batch-write-item \
        --request-items file://${local_file.initial_data[0].filename} \
        --region ${var.aws_region != "" ? var.aws_region : data.aws_region.current.id}
    EOT
  }

  depends_on = [
    aws_dynamodb_table.this,
    local_file.initial_data
  ]
}

# Generate JSON file for batch-write-item
resource "local_file" "initial_data" {
  count = var.populate_initial_data && length(var.initial_data_items) > 0 ? 1 : 0

  filename = "${path.module}/.terraform/dynamodb-initial-data-${var.table_name}.json"
  content = jsonencode({
    (var.table_name) = [
      for item in var.initial_data_items : {
        PutRequest = {
          Item = {
            for k, v in item : k => {
              for type, value in v : type => value
            }
          }
        }
      }
    ]
  })

  file_permission = "0644"
}

# Alternative: Use aws_dynamodb_table_item for individual items
# This is more suitable for small, static configuration data
resource "aws_dynamodb_table_item" "static_items" {
  for_each = var.use_terraform_items ? var.terraform_managed_items : {}

  table_name = aws_dynamodb_table.this.name
  hash_key   = aws_dynamodb_table.this.hash_key
  range_key  = aws_dynamodb_table.this.range_key

  item = jsonencode(each.value)

  lifecycle {
    ignore_changes = [item]
  }
}

# Data source for current region
data "aws_region" "current" {}
