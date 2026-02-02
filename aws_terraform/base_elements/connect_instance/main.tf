# ============================================
# AWS Connect Instance
# ============================================
# Create the main Amazon Connect instance with specified configuration
# This is the core resource that all other Connect components depend on

resource "aws_connect_instance" "main" {
  identity_management_type = var.identity_management_type
  inbound_calls_enabled    = var.inbound_calls_enabled
  instance_alias           = var.instance_alias
  outbound_calls_enabled   = var.outbound_calls_enabled

  # Optional directory integration for EXISTING_DIRECTORY type
  directory_id = var.directory_id

  # Enable contact flow logging to CloudWatch for debugging and monitoring
  contact_flow_logs_enabled = var.contact_flow_logs_enabled

  # Enable Contact Lens for analytics, sentiment analysis, and call categorization
  contact_lens_enabled = var.contact_lens_enabled

  # Auto resolve best voices improves text-to-speech quality
  auto_resolve_best_voices_enabled = var.auto_resolve_best_voices_enabled

  # Early media allows audio playback before call is answered (e.g., ringback tones)
  early_media_enabled = var.early_media_enabled

  # Multi-party conference enables more than 2 participants in a call
  multi_party_conference_enabled = var.multi_party_conference_enabled

  tags = merge(
    var.tags,
    var.instance_tags,
    {
      Name = var.instance_alias
    }
  )
}

# ============================================
# IAM Role for Connect Instance (if needed)
# ============================================
# Create IAM role for Connect instance to access other AWS services
# This role is used for service integrations like Lex, Lambda, and S3

data "aws_iam_policy_document" "connect_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["connect.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "connect_instance" {
  name               = "${var.instance_alias}-connect-instance-role"
  assume_role_policy = data.aws_iam_policy_document.connect_assume_role.json

  tags = var.tags
}

# Attach AWS managed policy for Connect access to common services
# Can be overridden with a custom policy ARN via connect_iam_policy_arn variable
# Set connect_iam_policy_arn to empty string to skip managed policy attachment
resource "aws_iam_role_policy_attachment" "connect_service_policy" {
  count = var.connect_iam_policy_arn != "" ? 1 : 0

  role       = aws_iam_role.connect_instance.name
  policy_arn = var.connect_iam_policy_arn
}

# ============================================
# CloudWatch Log Group for Contact Flows
# ============================================
# Create dedicated log group for contact flow logs with configurable retention
# This helps with debugging contact flow issues and tracking call flows

resource "aws_cloudwatch_log_group" "contact_flow_logs" {
  count = var.contact_flow_logs_enabled ? 1 : 0

  name              = "/aws/connect/${var.instance_alias}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ============================================
# Hours of Operation
# ============================================
# Define business hours for queues and routing
# These determine when agents are available and when to use after-hours flows

resource "aws_connect_hours_of_operation" "main" {
  for_each = { for hours in var.hours_of_operation : hours.name => hours }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description
  time_zone   = each.value.time_zone

  dynamic "config" {
    for_each = each.value.config
    content {
      day = config.value.day

      start_time {
        hours   = config.value.start_time.hours
        minutes = config.value.start_time.minutes
      }

      end_time {
        hours   = config.value.end_time.hours
        minutes = config.value.end_time.minutes
      }
    }
  }

  tags = var.tags
}

# ============================================
# Queues
# ============================================
# Create queues for managing incoming contacts
# Queues hold contacts until an available agent can handle them

resource "aws_connect_queue" "main" {
  for_each = { for queue in var.queues : queue.name => queue }

  instance_id           = aws_connect_instance.main.id
  name                  = each.value.name
  description           = each.value.description
  hours_of_operation_id = aws_connect_hours_of_operation.main[each.value.hours_of_operation_name].hours_of_operation_id

  # Maximum contacts allowed in the queue
  max_contacts = each.value.max_contacts

  # Outbound caller ID configuration
  outbound_caller_config {
    outbound_caller_id_name = each.value.outbound_caller_id_name
    # Only set phone number if provided and phone number exists
    outbound_caller_id_number_id = each.value.outbound_caller_id_number_key != null ? aws_connect_phone_number.main[each.value.outbound_caller_id_number_key].phone_number_id : null
  }

  # Queue status (ENABLED or DISABLED)
  status = each.value.status

  # Quick connects allow agents to transfer calls easily
  quick_connect_ids = [
    for qc_key in each.value.quick_connect_keys : aws_connect_quick_connect.main[qc_key].quick_connect_id
  ]

  tags = var.tags

  depends_on = [
    aws_connect_hours_of_operation.main,
    aws_connect_phone_number.main,
    aws_connect_quick_connect.main
  ]
}

# ============================================
# Routing Profiles
# ============================================
# Define how contacts are routed to agents
# Routing profiles specify which queues agents can handle and media concurrency

resource "aws_connect_routing_profile" "main" {
  for_each = { for profile in var.routing_profiles : profile.name => profile }

  instance_id               = aws_connect_instance.main.id
  name                      = each.value.name
  description               = each.value.description
  default_outbound_queue_id = aws_connect_queue.main[each.value.default_outbound_queue_name].queue_id

  # Media concurrency defines how many contacts of each type an agent can handle simultaneously
  dynamic "media_concurrencies" {
    for_each = each.value.media_concurrencies
    content {
      channel     = media_concurrencies.value.channel
      concurrency = media_concurrencies.value.concurrency
    }
  }

  # Queue configurations define priority and delay for each queue
  dynamic "queue_configs" {
    for_each = each.value.queue_configs
    content {
      channel  = queue_configs.value.channel
      delay    = queue_configs.value.delay
      priority = queue_configs.value.priority
      queue_id = aws_connect_queue.main[queue_configs.value.queue_name].queue_id
    }
  }

  tags = var.tags

  depends_on = [aws_connect_queue.main]
}

# ============================================
# Security Profiles
# ============================================
# Define permissions for users
# Security profiles control what actions users can perform in Connect

resource "aws_connect_security_profile" "main" {
  for_each = { for profile in var.security_profiles : profile.name => profile }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description

  # Permissions determine what actions users with this profile can perform
  permissions = each.value.permissions

  tags = var.tags
}

# ============================================
# Quick Connects
# ============================================
# Create quick connects for fast transfers and callbacks
# Quick connects allow agents to quickly transfer to queues, users, or external numbers

resource "aws_connect_quick_connect" "main" {
  for_each = var.quick_connects

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description

  quick_connect_config {
    quick_connect_type = each.value.type

    # Phone number configuration for external transfers
    dynamic "phone_config" {
      for_each = each.value.type == "PHONE_NUMBER" ? [1] : []
      content {
        phone_number = each.value.phone_number
      }
    }

    # Queue configuration for queue transfers
    dynamic "queue_config" {
      for_each = each.value.type == "QUEUE" ? [1] : []
      content {
        contact_flow_id = aws_connect_instance.main.id # Default flow
        queue_id        = aws_connect_queue.main[each.value.queue_name].queue_id
      }
    }

    # User configuration for agent transfers
    dynamic "user_config" {
      for_each = each.value.type == "USER" ? [1] : []
      content {
        contact_flow_id = aws_connect_instance.main.id # Default flow
        user_id         = aws_connect_user.main[each.value.user_name].user_id
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_connect_queue.main,
    aws_connect_user.main
  ]
}

# ============================================
# Phone Numbers
# ============================================
# Provision phone numbers for the Connect instance
# Phone numbers can be used for inbound calls and outbound caller ID

resource "aws_connect_phone_number" "main" {
  for_each = var.phone_numbers

  country_code = each.value.country_code
  type         = each.value.type
  description  = each.value.description

  # Associate with Connect instance
  target_arn = aws_connect_instance.main.arn

  tags = merge(
    var.tags,
    {
      Name        = each.key
      Description = each.value.description
    }
  )
}

# ============================================
# Contact Flows
# ============================================
# Create contact flows for call routing logic
# Contact flows define the customer experience and call flow logic

resource "aws_connect_contact_flow" "main" {
  for_each = { for flow in var.contact_flows : flow.name => flow }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description
  type        = each.value.type

  # Use inline content or read from file
  content = each.value.content != null ? each.value.content : (
    each.value.filename != null ? file(each.value.filename) : null
  )

  tags = var.tags
}

# ============================================
# Admin User (Optional)
# ============================================
# Create an admin user with full permissions
# Admin user is created with default Admin security profile

resource "aws_connect_user" "admin" {
  count = var.create_admin_user ? 1 : 0

  instance_id = aws_connect_instance.main.id
  name        = var.admin_user.username
  password    = var.admin_user.password

  identity_info {
    email      = var.admin_user.email
    first_name = var.admin_user.first_name
    last_name  = var.admin_user.last_name
  }

  phone_config {
    phone_type              = "SOFT_PHONE"
    auto_accept             = false
    after_contact_work_time_limit = 0
  }

  # Use the default Admin security profile from the data source
  # If no admin profiles are found, this will fail - manual assignment required
  security_profile_ids = data.aws_connect_security_profiles.admin.security_profile_summary_list[*].id

  # Use a basic routing profile (will be created first)
  routing_profile_id = length(var.routing_profiles) > 0 ? aws_connect_routing_profile.main[var.routing_profiles[0].name].routing_profile_id : null

  tags = var.tags

  depends_on = [
    aws_connect_routing_profile.main,
    aws_connect_security_profile.main
  ]
}

# Get default Admin security profile
data "aws_connect_security_profiles" "admin" {
  instance_id = aws_connect_instance.main.id
}

# ============================================
# Users
# ============================================
# Create users with specified configurations
# Users are agents who handle contacts in the contact center

resource "aws_connect_user" "main" {
  for_each = { for user in var.users : user.username => user }

  instance_id = aws_connect_instance.main.id
  name        = each.value.username
  password    = each.value.password

  identity_info {
    email      = each.value.email
    first_name = each.value.first_name
    last_name  = each.value.last_name
  }

  phone_config {
    phone_type                    = each.value.phone_type
    auto_accept                   = each.value.auto_accept
    after_contact_work_time_limit = each.value.after_contact_work_time
    desk_phone_number             = each.value.desk_phone_number
  }

  # Assign security profiles
  security_profile_ids = [
    for profile_name in each.value.security_profile_names : aws_connect_security_profile.main[profile_name].security_profile_id
  ]

  # Assign routing profile
  routing_profile_id = aws_connect_routing_profile.main[each.value.routing_profile_name].routing_profile_id

  # Hierarchy group assignment (optional)
  hierarchy_group_id = each.value.hierarchy_group_name != null ? aws_connect_user_hierarchy_group.main[each.value.hierarchy_group_name].hierarchy_group_id : null

  tags = var.tags

  depends_on = [
    aws_connect_routing_profile.main,
    aws_connect_security_profile.main
  ]
}

# ============================================
# User Hierarchy Groups (Optional)
# ============================================
# Create hierarchy groups for organizational structure
# Hierarchy groups allow you to organize users into teams/departments

locals {
  # Extract unique hierarchy group names from users
  hierarchy_groups = distinct(compact([for user in var.users : user.hierarchy_group_name if user.hierarchy_group_name != null]))
}

resource "aws_connect_user_hierarchy_group" "main" {
  for_each = toset(local.hierarchy_groups)

  instance_id = aws_connect_instance.main.id
  name        = each.value

  tags = var.tags
}

# ============================================
# Lambda Function Associations
# ============================================
# Associate Lambda functions with the Connect instance
# Lambda functions can be invoked from contact flows for custom logic

resource "aws_connect_lambda_function_association" "main" {
  for_each = var.lambda_functions

  instance_id  = aws_connect_instance.main.id
  function_arn = each.value.function_arn
}

# Grant Connect permission to invoke the Lambda functions
resource "aws_lambda_permission" "connect_invoke" {
  for_each = var.lambda_functions

  statement_id  = "AllowConnectInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_arn
  principal     = "connect.amazonaws.com"
  source_arn    = aws_connect_instance.main.arn
}

# ============================================
# Lex Bot Associations
# ============================================
# Associate Lex bots with the Connect instance
# Lex bots provide conversational AI capabilities in contact flows

data "aws_region" "current" {}

resource "aws_connect_bot_association" "main" {
  for_each = { for bot in var.lex_bots : bot.name => bot }

  instance_id = aws_connect_instance.main.id

  lex_bot {
    name       = each.value.name
    lex_region = each.value.lex_region != null ? each.value.lex_region : data.aws_region.current.name
  }
}
