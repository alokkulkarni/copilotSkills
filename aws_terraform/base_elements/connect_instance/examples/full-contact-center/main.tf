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
      Project     = "connect-full-example"
      ManagedBy   = "terraform"
      Example     = "full-contact-center"
    }
  }
}

# ============================================
# Full Contact Center with All Features
# ============================================
# This example demonstrates the full capabilities of the modular Connect module.
# Each section below maps to a dedicated module file:
# - phone_numbers.tf: Phone number provisioning
# - hours_of_operation.tf: Business hours configuration
# - queues.tf: Queue resources (Sales & Support)
# - routing_profiles.tf: Agent routing (Sales, Support, Supervisor)
# - security_profiles.tf: Role-based access control
# - quick_connects.tf: Fast transfer destinations
# - users.tf: User and hierarchy management
# - contact_flows.tf: Call flow logic
# You can add/modify any component independently via variables.

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
  multi_party_conference_enabled = true
  auto_resolve_best_voices_enabled = true

  # ============================================
  # Hours of Operation
  # ============================================
  hours_of_operation = [
    {
      name        = "BusinessHours"
      description = "Standard business hours - Monday to Friday, 9 AM to 5 PM"
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
    },
    {
      name        = "ExtendedHours"
      description = "Extended support hours - Monday to Saturday, 8 AM to 8 PM"
      time_zone   = var.time_zone
      config = [
        {
          day        = "MONDAY"
          start_time = { hours = 8, minutes = 0 }
          end_time   = { hours = 20, minutes = 0 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 8, minutes = 0 }
          end_time   = { hours = 20, minutes = 0 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 8, minutes = 0 }
          end_time   = { hours = 20, minutes = 0 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 8, minutes = 0 }
          end_time   = { hours = 20, minutes = 0 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 8, minutes = 0 }
          end_time   = { hours = 20, minutes = 0 }
        },
        {
          day        = "SATURDAY"
          start_time = { hours = 10, minutes = 0 }
          end_time   = { hours = 18, minutes = 0 }
        }
      ]
    }
  ]

  # ============================================
  # Phone Numbers (Optional)
  # ============================================
  phone_numbers = var.provision_phone_numbers ? {
    main_line = {
      country_code = var.phone_country_code
      type         = "DID"
      description  = "Main customer service line"
    }
    toll_free = {
      country_code = var.phone_country_code
      type         = "TOLL_FREE"
      description  = "Toll-free support line"
    }
  } : {}

  # ============================================
  # Queues
  # ============================================
  queues = [
    {
      name                          = "SalesQueue"
      description                   = "Queue for sales inquiries"
      hours_of_operation_name       = "BusinessHours"
      max_contacts                  = 100
      outbound_caller_id_name       = "Sales Team"
      outbound_caller_id_number_key = var.provision_phone_numbers ? "main_line" : null
      status                        = "ENABLED"
      quick_connect_keys            = ["sales_supervisor"]
    },
    {
      name                          = "SupportQueue"
      description                   = "Queue for technical support"
      hours_of_operation_name       = "ExtendedHours"
      max_contacts                  = 150
      outbound_caller_id_name       = "Support Team"
      outbound_caller_id_number_key = var.provision_phone_numbers ? "toll_free" : null
      status                        = "ENABLED"
      quick_connect_keys            = ["support_supervisor"]
    }
  ]

  # ============================================
  # Routing Profiles
  # ============================================
  routing_profiles = [
    {
      name                        = "SalesAgentProfile"
      description                 = "Routing profile for sales agents"
      default_outbound_queue_name = "SalesQueue"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        },
        {
          channel     = "CHAT"
          concurrency = 2
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "SalesQueue"
        }
      ]
    },
    {
      name                        = "SupportAgentProfile"
      description                 = "Routing profile for support agents"
      default_outbound_queue_name = "SupportQueue"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        },
        {
          channel     = "CHAT"
          concurrency = 3
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "SupportQueue"
        }
      ]
    },
    {
      name                        = "SupervisorProfile"
      description                 = "Routing profile for supervisors"
      default_outbound_queue_name = "SalesQueue"
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
          queue_name = "SalesQueue"
        },
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "SupportQueue"
        }
      ]
    }
  ]

  # ============================================
  # Security Profiles
  # ============================================
  security_profiles = [
    {
      name        = "SalesAgentAccess"
      description = "Security profile for sales agents"
      permissions = [
        "BasicAgentAccess",
        "OutboundCallAccess"
      ]
    },
    {
      name        = "SupportAgentAccess"
      description = "Security profile for support agents"
      permissions = [
        "BasicAgentAccess",
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
    sales_supervisor = {
      name        = "SalesSupervisor"
      description = "Quick connect to sales supervisor"
      type        = "USER"
      user_name   = "sales.supervisor"
    }
    support_supervisor = {
      name        = "SupportSupervisor"
      description = "Quick connect to support supervisor"
      type        = "USER"
      user_name   = "support.supervisor"
    }
  }

  # ============================================
  # Users
  # ============================================
  users = [
    # Sales Supervisor
    {
      username                 = "sales.supervisor"
      email                    = "sales.supervisor@example.com"
      first_name              = "Sales"
      last_name               = "Supervisor"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "SupervisorProfile"
      security_profile_names  = ["SupervisorAccess"]
      hierarchy_group_name    = "Sales"
    },
    # Sales Agents
    {
      username                 = "sales.agent1"
      email                    = "sales.agent1@example.com"
      first_name              = "Sarah"
      last_name               = "Johnson"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "SalesAgentProfile"
      security_profile_names  = ["SalesAgentAccess"]
      hierarchy_group_name    = "Sales"
    },
    {
      username                 = "sales.agent2"
      email                    = "sales.agent2@example.com"
      first_name              = "Mike"
      last_name               = "Chen"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "SalesAgentProfile"
      security_profile_names  = ["SalesAgentAccess"]
      hierarchy_group_name    = "Sales"
    },
    # Support Supervisor
    {
      username                 = "support.supervisor"
      email                    = "support.supervisor@example.com"
      first_name              = "Support"
      last_name               = "Supervisor"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 30
      routing_profile_name    = "SupervisorProfile"
      security_profile_names  = ["SupervisorAccess"]
      hierarchy_group_name    = "Support"
    },
    # Support Agents
    {
      username                 = "support.agent1"
      email                    = "support.agent1@example.com"
      first_name              = "Emily"
      last_name               = "Davis"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 60
      routing_profile_name    = "SupportAgentProfile"
      security_profile_names  = ["SupportAgentAccess"]
      hierarchy_group_name    = "Support"
    },
    {
      username                 = "support.agent2"
      email                    = "support.agent2@example.com"
      first_name              = "David"
      last_name               = "Martinez"
      phone_type              = "SOFT_PHONE"
      auto_accept             = false
      after_contact_work_time = 60
      routing_profile_name    = "SupportAgentProfile"
      security_profile_names  = ["SupportAgentAccess"]
      hierarchy_group_name    = "Support"
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
      name        = "MainInboundFlow"
      description = "Main inbound contact flow with hours check"
      type        = "CONTACT_FLOW"
      filename    = "${path.module}/contact-flows/basic-flow.json"
    }
  ]

  tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
  }
}
