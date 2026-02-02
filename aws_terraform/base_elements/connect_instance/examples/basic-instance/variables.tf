variable "aws_region" {
  description = "AWS region for Connect instance"
  type        = string
  default     = "eu-west-2"
}

variable "instance_alias" {
  description = "Alias for the Connect instance"
  type        = string
  default     = "basic-connect-dev"
}

variable "time_zone" {
  description = "Time zone for hours of operation"
  type        = string
  default     = "Europe/London"
}

variable "test_user_username" {
  description = "Username for the test agent"
  type        = string
  default     = "test.agent"
}

variable "test_user_email" {
  description = "Email for the test agent"
  type        = string
  default     = "test.agent@example.com"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
