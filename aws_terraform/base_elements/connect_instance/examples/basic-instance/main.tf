terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "connect-basic-example"
      ManagedBy   = "terraform"
      Example     = "basic-instance"
    }
  }
}

# ============================================
# Basic Connect Instance
# ============================================

module "connect" {
  source = "../../"

  # Core configuration
  instance_alias           = var.instance_alias
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = false # Disable outbound for basic setup
  contact_flow_logs_enabled = true

  # Define business hours (Monday to Friday, 9 AM to 5 PM)
  hours_of_operation = [
    {
      name        = "BusinessHours"
      description = "Standard business hours"
      time_zone   = var.time_zone
      config = [
        {
          day        = "MONDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        }
      ]
    }
  ]

  # Create a basic queue
  queues = [
    {
      name                    = "BasicQueue"
      description             = "Basic customer service queue"
      hours_of_operation_name = "BusinessHours"
      max_contacts            = 50
      status                  = "ENABLED"
      quick_connect_keys      = []
    }
  ]

  # Create a basic routing profile
  routing_profiles = [
    {
      name                        = "BasicAgentProfile"
      description                 = "Basic agent routing profile"
      default_outbound_queue_name = "BasicQueue"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "BasicQueue"
        }
      ]
    }
  ]

  # Create a basic security profile
  security_profiles = [
    {
      name        = "BasicAgentAccess"
      description = "Basic agent access permissions"
      permissions = [
        "BasicAgentAccess"
      ]
    }
  ]

  # Create a test user
  users = [
    {
      username                 = var.test_user_username
      email                    = var.test_user_email
      first_name              = "Test"
      last_name               = "Agent"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "BasicAgentProfile"
      security_profile_names  = ["BasicAgentAccess"]
    }
  ]

  tags = {
    Environment = var.environment
  }
}
