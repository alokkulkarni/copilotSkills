# ============================================
# Variables for DynamoDB Table Module
# ============================================

# ------------------
# Table Configuration
# ------------------

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "read_capacity" {
  description = "Number of read units for the table (only for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Number of write units for the table (only for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "hash_key" {
  description = "Attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "Attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "table_class" {
  description = "Storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be either STANDARD or STANDARD_INFREQUENT_ACCESS"
  }
}

# ------------------
# Attributes
# ------------------

variable "attributes" {
  description = "List of attributes for the table (only include keys and GSI/LSI keys)"
  type = list(object({
    name = string
    type = string
  }))

  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be S (string), N (number), or B (binary)"
  }
}

# ------------------
# Indexes
# ------------------

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# ------------------
# TTL Configuration
# ------------------

variable "ttl_enabled" {
  description = "Enable Time to Live for the table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the attribute to store the TTL timestamp"
  type        = string
  default     = "ttl"
}

# ------------------
# Encryption
# ------------------

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption (null for AWS managed key)"
  type        = string
  default     = null
}

# ------------------
# Point-in-Time Recovery
# ------------------

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

# ------------------
# Streams
# ------------------

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of data written to the stream (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  }
}

variable "enable_stream_lambda_triggers" {
  description = "Enable Lambda triggers for DynamoDB streams"
  type        = bool
  default     = false
}

variable "stream_lambda_functions" {
  description = "Map of Lambda functions to trigger from DynamoDB streams"
  type = map(object({
    function_name                      = string
    starting_position                  = string
    batch_size                         = optional(number, 100)
    maximum_batching_window_in_seconds = optional(number, 0)
    parallelization_factor             = optional(number, 1)
    maximum_retry_attempts             = optional(number, -1)
    maximum_record_age_in_seconds      = optional(number, -1)
    bisect_batch_on_function_error     = optional(bool, false)
    enabled                            = optional(bool, true)
    on_failure_destination             = optional(string)
    filter_pattern                     = optional(string)
  }))
  default = {}
}

variable "create_stream_log_group" {
  description = "Create CloudWatch log group for stream processing"
  type        = bool
  default     = false
}

variable "stream_log_retention_days" {
  description = "Retention period for stream processing logs"
  type        = number
  default     = 7
}

variable "log_kms_key_arn" {
  description = "ARN of KMS key for CloudWatch logs encryption"
  type        = string
  default     = null
}

variable "enable_kinesis_destination" {
  description = "Enable Kinesis Data Streams destination for DynamoDB"
  type        = bool
  default     = false
}

variable "kinesis_stream_arn" {
  description = "ARN of Kinesis Data Stream for DynamoDB streaming destination"
  type        = string
  default     = null
}

# ------------------
# Protection
# ------------------

variable "deletion_protection" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = false
}

# ------------------
# Global Tables
# ------------------

variable "replica_regions" {
  description = "List of regions for global table replicas"
  type = list(object({
    region_name            = string
    kms_key_arn            = optional(string)
    propagate_tags         = optional(bool, false)
    point_in_time_recovery = optional(bool)
  }))
  default = []
}

# ------------------
# Auto-Scaling
# ------------------

variable "enable_autoscaling" {
  description = "Enable auto-scaling for provisioned capacity"
  type        = bool
  default     = false
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_read_target" {
  description = "Target utilization percentage for read capacity"
  type        = number
  default     = 70
}

variable "autoscaling_write_target" {
  description = "Target utilization percentage for write capacity"
  type        = number
  default     = 70
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown period (seconds) before allowing another scale-in"
  type        = number
  default     = 60
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown period (seconds) before allowing another scale-out"
  type        = number
  default     = 60
}

# ------------------
# IAM Configuration
# ------------------

variable "create_lambda_access_policy" {
  description = "Create IAM policy for Lambda access to DynamoDB"
  type        = bool
  default     = false
}

variable "lambda_function_names" {
  description = "Set of Lambda function names to grant DynamoDB access"
  type        = set(string)
  default     = []
}

variable "create_read_only_policy" {
  description = "Create IAM policy for read-only access"
  type        = bool
  default     = false
}

variable "create_write_only_policy" {
  description = "Create IAM policy for write-only access"
  type        = bool
  default     = false
}

variable "custom_iam_policy" {
  description = "Custom IAM policy JSON for DynamoDB access"
  type        = string
  default     = null
}

# ------------------
# Data Population
# ------------------

variable "populate_initial_data" {
  description = "Populate table with initial data"
  type        = bool
  default     = false
}

variable "initial_data_items" {
  description = "List of items to insert into the table (for batch-write-item)"
  type        = list(map(map(any)))
  default     = []
}

variable "aws_cli_path" {
  description = "Path to AWS CLI executable"
  type        = string
  default     = "aws"
}

variable "aws_region" {
  description = "AWS region for data population (uses current region if empty)"
  type        = string
  default     = ""
}

variable "use_terraform_items" {
  description = "Use Terraform-managed items (aws_dynamodb_table_item) instead of batch-write"
  type        = bool
  default     = false
}

variable "terraform_managed_items" {
  description = "Map of Terraform-managed items (key = item identifier, value = item JSON)"
  type        = map(map(any))
  default     = {}
}

# ------------------
# Backup Configuration
# ------------------

variable "enable_backup_vault" {
  description = "Create AWS Backup vault for DynamoDB backups"
  type        = bool
  default     = false
}

variable "backup_vault_kms_key_arn" {
  description = "KMS key ARN for backup vault encryption"
  type        = string
  default     = null
}

variable "enable_backup_plan" {
  description = "Create AWS Backup plan for automated backups"
  type        = bool
  default     = false
}

variable "existing_backup_vault_name" {
  description = "Name of existing backup vault (if not creating new one)"
  type        = string
  default     = null
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_cold_storage_after_days" {
  description = "Number of days after which to transition to cold storage (null for never)"
  type        = number
  default     = null
}

variable "enable_weekly_backup" {
  description = "Enable additional weekly backup rule"
  type        = bool
  default     = false
}

variable "backup_weekly_retention_days" {
  description = "Retention period for weekly backups"
  type        = number
  default     = 90
}

variable "create_manual_backup" {
  description = "Create a manual on-demand backup"
  type        = bool
  default     = false
}

# ------------------
# Tags
# ------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
