# ============================================
# Lambda Layer Core Configuration
# ============================================

variable "layer_name" {
  description = "Unique name for the Lambda layer"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.layer_name))
    error_message = "Layer name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "description" {
  description = "Description of the Lambda layer"
  type        = string
  default     = ""
}

# ============================================
# Layer Code Source Configuration
# ============================================

variable "filename" {
  description = "Path to the local zip file containing the layer code. Mutually exclusive with s3_bucket"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the layer code. Mutually exclusive with filename"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the layer code zip file. Required if s3_bucket is set"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the layer code. Optional"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the layer code. Used to trigger updates"
  type        = string
  default     = null
}

# ============================================
# Runtime Compatibility
# ============================================

variable "compatible_runtimes" {
  description = "List of Lambda runtimes that can use this layer. Example: ['python3.9', 'python3.10', 'python3.11']"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for runtime in var.compatible_runtimes :
      can(regex("^(nodejs|python|ruby|java|go|dotnet|provided)", runtime))
    ])
    error_message = "Compatible runtimes must be valid Lambda runtime identifiers."
  }
}

variable "license_info" {
  description = "License information for the layer. Example: 'MIT', 'Apache-2.0'"
  type        = string
  default     = null
}

# ============================================
# Layer Permissions Configuration
# ============================================

variable "enable_layer_permissions" {
  description = "Enable permissions for other AWS accounts or organizations to use this layer"
  type        = bool
  default     = false
}

variable "permission_action" {
  description = "Lambda API action for layer permission. Typically 'lambda:GetLayerVersion'"
  type        = string
  default     = "lambda:GetLayerVersion"
}

variable "permission_principal" {
  description = "AWS principal (account ID or *) allowed to use the layer"
  type        = string
  default     = "*"
}

variable "organization_id" {
  description = "AWS organization ID to grant layer permissions. Optional"
  type        = string
  default     = null
}

variable "permission_statement_id" {
  description = "Unique statement ID for the layer permission"
  type        = string
  default     = "AllowLayerAccess"
}
