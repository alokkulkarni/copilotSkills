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
      Environment = var.environment
      Project     = "connect-ai-integration"
      ManagedBy   = "terraform"
      Example     = "lex-lambda-integration"
    }
  }
}

# ============================================
# Connect Instance with Lex and Lambda Integration
# ============================================

module "connect" {
  source = "../../"

  # Core configuration
  instance_alias              = var.instance_alias
  identity_management_type    = "CONNECT_MANAGED"
  inbound_calls_enabled       = true
  outbound_calls_enabled      = true
  contact_flow_logs_enabled   = true
  contact_lens_enabled        = var.enable_contact_lens
  early_media_enabled         = true
  auto_resolve_best_voices_enabled = true

  # ============================================
  # Hours of Operation
  # ============================================
  hours_of_operation = [
    {
      name        = "TwentyFourSeven"
      description = "24/7 availability for AI-powered support"
      time_zone   = var.time_zone
      config = [
        {
          day        = "MONDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "SATURDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "SUNDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        }
      ]
    }
  ]

  # ============================================
  # Queues
  # ============================================
  queues = [
    {
      name                    = "AIEscalationQueue"
      description             = "Queue for AI-escalated customer contacts"
      hours_of_operation_name = "TwentyFourSeven"
      max_contacts            = 200
      outbound_caller_id_name = "Customer Service"
      status                  = "ENABLED"
      quick_connect_keys      = ["supervisor"]
    }
  ]

  # ============================================
  # Routing Profiles
  # ============================================
  routing_profiles = [
    {
      name                        = "AIAgentProfile"
      description                 = "Routing profile for agents handling AI-escalated contacts"
      default_outbound_queue_name = "AIEscalationQueue"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 2
        },
        {
          channel     = "CHAT"
          concurrency = 5
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "AIEscalationQueue"
        }
      ]
    },
    {
      name                        = "SupervisorProfile"
      description                 = "Routing profile for supervisors"
      default_outbound_queue_name = "AIEscalationQueue"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 3
        },
        {
          channel     = "CHAT"
          concurrency = 10
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "AIEscalationQueue"
        }
      ]
    }
  ]

  # ============================================
  # Security Profiles
  # ============================================
  security_profiles = [
    {
      name        = "AIAgentAccess"
      description = "Security profile for AI-assisted agents"
      permissions = [
        "BasicAgentAccess",
        "OutboundCallAccess",
        "AccessMetrics"
      ]
    },
    {
      name        = "SupervisorAccess"
      description = "Security profile for supervisors"
      permissions = [
        "BasicAgentAccess",
        "OutboundCallAccess",
        "AccessMetrics",
        "ManagerListenIn",
        "ManagerBargeIn"
      ]
    }
  ]

  # ============================================
  # Quick Connects
  # ============================================
  quick_connects = {
    supervisor = {
      name        = "Supervisor"
      description = "Quick connect to supervisor"
      type        = "USER"
      user_name   = "supervisor"
    }
  }

  # ============================================
  # Users
  # ============================================
  users = [
    {
      username                 = "supervisor"
      email                    = var.supervisor_email
      first_name              = "AI"
      last_name               = "Supervisor"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "SupervisorProfile"
      security_profile_names  = ["SupervisorAccess"]
    },
    {
      username                 = "agent1"
      email                    = var.agent1_email
      first_name              = "Alex"
      last_name               = "Anderson"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 60
      routing_profile_name    = "AIAgentProfile"
      security_profile_names  = ["AIAgentAccess"]
    },
    {
      username                 = "agent2"
      email                    = var.agent2_email
      first_name              = "Jordan"
      last_name               = "Williams"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 60
      routing_profile_name    = "AIAgentProfile"
      security_profile_names  = ["AIAgentAccess"]
    }
  ]

  # ============================================
  # Admin User
  # ============================================
  create_admin_user = var.create_admin_user
  admin_user = {
    username   = "admin"
    email      = var.admin_email
    first_name = "Admin"
    last_name  = "User"
  }

  # ============================================
  # Contact Flows
  # ============================================
  contact_flows = [
    {
      name        = "LexLambdaFlow"
      description = "Contact flow with Lex bot and Lambda integration"
      type        = "CONTACT_FLOW"
      filename    = "${path.module}/contact-flows/lex-bot-flow.json"
    }
  ]

  # ============================================
  # Lambda Function Integration
  # ============================================
  lambda_functions = var.lambda_arn != "" ? {
    customer_service = {
      function_arn = var.lambda_arn
    }
  } : {}

  # ============================================
  # Lex Bot Integration
  # ============================================
  lex_bots = var.lex_bot_name != "" ? [
    {
      name       = var.lex_bot_name
      lex_region = var.lex_region != "" ? var.lex_region : var.aws_region
    }
  ] : []

  tags = {
    Environment = var.environment
    UseCase     = "AI-Powered Customer Service"
  }
}

# ============================================
# Outputs for Contact Flow Attributes
# ============================================

# These outputs can be used to set contact attributes in the contact flow
output "contact_flow_attributes" {
  description = "Attributes to set in contact flow for Lex and Lambda integration"
  value = {
    LexBotName      = var.lex_bot_name
    LexBotRegion    = var.lex_region != "" ? var.lex_region : var.aws_region
    LexBotAlias     = var.lex_bot_alias
    LambdaFunctionARN = var.lambda_arn
    QueueId         = length(module.connect.queue_ids) > 0 ? module.connect.queue_ids["AIEscalationQueue"] : ""
  }
}
