# ============================================
# Lambda Function Core Configuration
# ============================================

variable "function_name" {
  description = "Unique name for the Lambda function"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name)) && length(var.function_name) <= 64
    error_message = "Function name must contain only alphanumeric characters, hyphens, and underscores, and be 64 characters or less."
  }
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

# ============================================
# Function Code Configuration
# ============================================

variable "filename" {
  description = "Path to the local zip file containing the function code. Mutually exclusive with s3_bucket and image_uri"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the function code. Mutually exclusive with filename"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the function code zip file. Required if s3_bucket is set"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the function code. Optional"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the function code. Used to trigger updates"
  type        = string
  default     = null
}

# ============================================
# Runtime Configuration
# ============================================

variable "handler" {
  description = "Function entrypoint in your code. Format: filename.handler_function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier. Example: python3.11, nodejs20.x, java21"
  type        = string

  validation {
    condition = can(regex("^(nodejs|python|ruby|java|go|dotnet|provided)", var.runtime))
    error_message = "Runtime must be a valid Lambda runtime identifier."
  }
}

variable "timeout" {
  description = "Amount of time Lambda function has to run in seconds (1-900)"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB available to the function (128-10240)"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this function (-1 for unreserved)"
  type        = number
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions == -1 || var.reserved_concurrent_executions >= 0
    error_message = "Reserved concurrent executions must be -1 (unreserved) or a positive number."
  }
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda function version"
  type        = bool
  default     = false
}

variable "architectures" {
  description = "Instruction set architecture for the Lambda function. Valid values: ['x86_64'] or ['arm64']"
  type        = list(string)
  default     = ["x86_64"]

  validation {
    condition = alltrue([
      for arch in var.architectures :
      contains(["x86_64", "arm64"], arch)
    ])
    error_message = "Architectures must be either 'x86_64' or 'arm64'."
  }
}

# ============================================
# Lambda Layers Configuration
# ============================================

variable "layers" {
  description = "List of Lambda layer ARNs to attach to the function. Max 5 layers"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.layers) <= 5
    error_message = "Maximum of 5 layers can be attached to a Lambda function."
  }
}

# ============================================
# Environment Variables
# ============================================

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = null
  sensitive   = true
}

# ============================================
# VPC Configuration
# ============================================

variable "vpc_config" {
  description = "VPC configuration for Lambda function. Object with subnet_ids and security_group_ids"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# ============================================
# IAM Role Configuration
# ============================================

variable "create_role" {
  description = "Whether to create a new IAM role for the Lambda function"
  type        = bool
  default     = true
}

variable "lambda_role_arn" {
  description = "ARN of an existing IAM role to use for the Lambda function. Required if create_role is false"
  type        = string
  default     = null
}

variable "attach_cloudwatch_logs_policy" {
  description = "Whether to attach AWS managed CloudWatch Logs policy to the Lambda role"
  type        = bool
  default     = true
}

variable "attach_policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "JSON-encoded IAM inline policy to attach to the Lambda role"
  type        = string
  default     = null
}

# ============================================
# CloudWatch Logs Configuration
# ============================================

variable "create_log_group" {
  description = "Whether to create a CloudWatch Log Group for the Lambda function"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda function logs in CloudWatch"
  type        = number
  default     = 14

  validation {
    condition = contains([
      0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID to use for encrypting Lambda function logs"
  type        = string
  default     = null
}

# ============================================
# Dead Letter Queue Configuration
# ============================================

variable "dead_letter_target_arn" {
  description = "ARN of an SNS topic or SQS queue for failed asynchronous invocations"
  type        = string
  default     = null
}

# ============================================
# X-Ray Tracing Configuration
# ============================================

variable "tracing_mode" {
  description = "X-Ray tracing mode. Valid values: 'Active' or 'PassThrough'"
  type        = string
  default     = null

  validation {
    condition     = var.tracing_mode == null || contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be 'Active' or 'PassThrough'."
  }
}

# ============================================
# Storage Configuration
# ============================================

variable "ephemeral_storage_size" {
  description = "Size of the Lambda function's /tmp directory in MB (512-10240)"
  type        = number
  default     = null

  validation {
    condition     = var.ephemeral_storage_size == null || (var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240)
    error_message = "Ephemeral storage size must be between 512 and 10240 MB."
  }
}

variable "file_system_config" {
  description = "EFS file system configuration. Object with arn and local_mount_path"
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

# ============================================
# Container Image Configuration
# ============================================

variable "image_config" {
  description = "Container image configuration. Object with command, entry_point, and working_directory"
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  default = null
}

# ============================================
# Code Signing Configuration
# ============================================

variable "code_signing_config_arn" {
  description = "ARN of a code signing configuration for the function"
  type        = string
  default     = null
}

# ============================================
# Snap Start Configuration (Java)
# ============================================

variable "snap_start_apply_on" {
  description = "Snap start setting. Valid value: 'PublishedVersions' (Java runtime only)"
  type        = string
  default     = null

  validation {
    condition     = var.snap_start_apply_on == null || var.snap_start_apply_on == "PublishedVersions"
    error_message = "Snap start apply_on must be 'PublishedVersions' or null."
  }
}

# ============================================
# Function URL Configuration
# ============================================

variable "create_function_url" {
  description = "Whether to create a Function URL for the Lambda function"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authorization type for Function URL. Valid values: 'AWS_IAM' or 'NONE'"
  type        = string
  default     = "AWS_IAM"

  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_auth_type)
    error_message = "Function URL auth type must be 'AWS_IAM' or 'NONE'."
  }
}

variable "function_url_cors_config" {
  description = "CORS configuration for Function URL"
  type = object({
    allow_credentials = optional(bool)
    allow_headers     = optional(list(string))
    allow_methods     = optional(list(string))
    allow_origins     = optional(list(string))
    expose_headers    = optional(list(string))
    max_age           = optional(number)
  })
  default = null
}

# ============================================
# Lambda Alias Configuration
# ============================================

variable "create_alias" {
  description = "Whether to create an alias for the Lambda function"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Name for the Lambda function alias"
  type        = string
  default     = "live"
}

variable "alias_description" {
  description = "Description for the Lambda function alias"
  type        = string
  default     = ""
}

variable "alias_function_version" {
  description = "Lambda function version for the alias. Use '$LATEST' or version number"
  type        = string
  default     = "$LATEST"
}

variable "alias_routing_config" {
  description = "Routing configuration for the alias (for weighted alias routing)"
  type = object({
    additional_version_weights = map(number)
  })
  default = null
}

# ============================================
# Tags
# ============================================

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
