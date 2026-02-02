variable "aws_region" {
  description = "AWS region for Connect instance"
  type        = string
  default     = "eu-west-2"
}

variable "instance_alias" {
  description = "Alias for the Connect instance (must be unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance_alias))
    error_message = "Instance alias must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "time_zone" {
  description = "Time zone for hours of operation"
  type        = string
  default     = "Europe/London"
}

variable "enable_contact_lens" {
  description = "Enable Contact Lens for analytics"
  type        = bool
  default     = false
}

variable "create_admin_user" {
  description = "Create an admin user"
  type        = bool
  default     = true
}

# ============================================
# User Email Addresses
# ============================================

variable "admin_email" {
  description = "Email address for admin user"
  type        = string
  default     = "admin@example.com"
}

variable "supervisor_email" {
  description = "Email address for supervisor"
  type        = string
  default     = "supervisor@example.com"
}

variable "agent1_email" {
  description = "Email address for agent 1"
  type        = string
  default     = "agent1@example.com"
}

variable "agent2_email" {
  description = "Email address for agent 2"
  type        = string
  default     = "agent2@example.com"
}

# ============================================
# Lex Bot Configuration
# ============================================

variable "lex_bot_name" {
  description = "Name of the Lex bot to associate with Connect"
  type        = string
  default     = ""
}

variable "lex_bot_alias" {
  description = "Alias of the Lex bot"
  type        = string
  default     = "PROD"
}

variable "lex_region" {
  description = "Region where Lex bot is deployed (defaults to aws_region)"
  type        = string
  default     = ""
}

# ============================================
# Lambda Function Configuration
# ============================================

variable "lambda_arn" {
  description = "ARN of the Lambda function to associate with Connect"
  type        = string
  default     = ""
}
