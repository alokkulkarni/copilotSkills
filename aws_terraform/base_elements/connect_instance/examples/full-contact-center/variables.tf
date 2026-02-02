variable "aws_region" {
  description = "AWS region for Connect instance"
  type        = string
  default     = "eu-west-2"
}

variable "instance_alias" {
  description = "Alias for the Connect instance (must be unique across AWS account)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance_alias))
    error_message = "Instance alias must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"

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

variable "provision_phone_numbers" {
  description = "Whether to provision phone numbers (may require service quota increase)"
  type        = bool
  default     = false
}

variable "phone_country_code" {
  description = "Country code for phone numbers (ISO format)"
  type        = string
  default     = "GB"
}

variable "enable_contact_lens" {
  description = "Enable Contact Lens for analytics (additional cost)"
  type        = bool
  default     = false
}

variable "create_admin_user" {
  description = "Create an admin user for the Connect instance"
  type        = bool
  default     = true
}

variable "admin_email" {
  description = "Email address for the admin user"
  type        = string
  default     = "admin@example.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "Admin email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center tag for billing"
  type        = string
  default     = "customer-service"
}
