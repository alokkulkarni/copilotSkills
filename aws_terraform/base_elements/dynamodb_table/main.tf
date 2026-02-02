# ============================================
# DynamoDB Table
# ============================================
# Core DynamoDB table resource with comprehensive configuration
# Related components are in separate files:
# - iam.tf: IAM roles and policies for Lambda access
# - autoscaling.tf: Auto-scaling for read/write capacity
# - data.tf: Initial data population
# - backup.tf: Backup and point-in-time recovery
# - streams.tf: DynamoDB streams configuration

resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = var.hash_key
  range_key      = var.range_key

  # Table class (STANDARD or STANDARD_INFREQUENT_ACCESS)
  table_class = var.table_class

  # Time to Live
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Attributes (only include keys and GSI/LSI keys)
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", var.read_capacity) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", var.write_capacity) : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Server-side encryption
  dynamic "server_side_encryption" {
    for_each = var.enable_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  # DynamoDB Streams
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  # Deletion protection
  deletion_protection_enabled = var.deletion_protection

  # Replica configuration for global tables
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name            = replica.value.region_name
      kms_key_arn           = lookup(replica.value, "kms_key_arn", null)
      propagate_tags        = lookup(replica.value, "propagate_tags", false)
      point_in_time_recovery = lookup(replica.value, "point_in_time_recovery", var.point_in_time_recovery)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      # Ignore read/write capacity changes if using auto-scaling
      read_capacity,
      write_capacity
    ]
  }
}
