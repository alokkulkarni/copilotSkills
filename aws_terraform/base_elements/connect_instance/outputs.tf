# ============================================
# Connect Instance Outputs
# ============================================

output "instance_id" {
  description = "The identifier of the Connect instance"
  value       = aws_connect_instance.main.id
}

output "instance_arn" {
  description = "Amazon Resource Name (ARN) of the instance"
  value       = aws_connect_instance.main.arn
}

output "instance_status" {
  description = "The state of the instance"
  value       = aws_connect_instance.main.status
}

output "instance_service_role" {
  description = "The service role of the instance"
  value       = aws_connect_instance.main.service_role
}

output "instance_created_time" {
  description = "When the instance was created"
  value       = aws_connect_instance.main.created_time
}

output "instance_alias" {
  description = "The alias of the Connect instance"
  value       = aws_connect_instance.main.instance_alias
}

# ============================================
# Hours of Operation Outputs
# ============================================

output "hours_of_operation_ids" {
  description = "Map of hours of operation names to their IDs"
  value = {
    for k, v in aws_connect_hours_of_operation.main : k => v.hours_of_operation_id
  }
}

output "hours_of_operation_arns" {
  description = "Map of hours of operation names to their ARNs"
  value = {
    for k, v in aws_connect_hours_of_operation.main : k => v.hours_of_operation_arn
  }
}

# ============================================
# Queue Outputs
# ============================================

output "queue_ids" {
  description = "Map of queue names to their IDs"
  value = {
    for k, v in aws_connect_queue.main : k => v.queue_id
  }
}

output "queue_arns" {
  description = "Map of queue names to their ARNs"
  value = {
    for k, v in aws_connect_queue.main : k => v.arn
  }
}

# ============================================
# Routing Profile Outputs
# ============================================

output "routing_profile_ids" {
  description = "Map of routing profile names to their IDs"
  value = {
    for k, v in aws_connect_routing_profile.main : k => v.routing_profile_id
  }
}

output "routing_profile_arns" {
  description = "Map of routing profile names to their ARNs"
  value = {
    for k, v in aws_connect_routing_profile.main : k => v.routing_profile_arn
  }
}

# ============================================
# Security Profile Outputs
# ============================================

output "security_profile_ids" {
  description = "Map of security profile names to their IDs"
  value = {
    for k, v in aws_connect_security_profile.main : k => v.security_profile_id
  }
}

output "security_profile_arns" {
  description = "Map of security profile names to their ARNs"
  value = {
    for k, v in aws_connect_security_profile.main : k => v.security_profile_arn
  }
}

# ============================================
# Quick Connect Outputs
# ============================================

output "quick_connect_ids" {
  description = "Map of quick connect keys to their IDs"
  value = {
    for k, v in aws_connect_quick_connect.main : k => v.quick_connect_id
  }
}

output "quick_connect_arns" {
  description = "Map of quick connect keys to their ARNs"
  value = {
    for k, v in aws_connect_quick_connect.main : k => v.quick_connect_arn
  }
}

# ============================================
# Phone Number Outputs
# ============================================

output "phone_number_ids" {
  description = "Map of phone number keys to their IDs"
  value = {
    for k, v in aws_connect_phone_number.main : k => v.phone_number_id
  }
}

output "phone_number_arns" {
  description = "Map of phone number keys to their ARNs"
  value = {
    for k, v in aws_connect_phone_number.main : k => v.arn
  }
}

output "phone_numbers" {
  description = "Map of phone number keys to their actual phone numbers"
  value = {
    for k, v in aws_connect_phone_number.main : k => v.phone_number
  }
}

# ============================================
# Contact Flow Outputs
# ============================================

output "contact_flow_ids" {
  description = "Map of contact flow names to their IDs"
  value = {
    for k, v in aws_connect_contact_flow.main : k => v.contact_flow_id
  }
}

output "contact_flow_arns" {
  description = "Map of contact flow names to their ARNs"
  value = {
    for k, v in aws_connect_contact_flow.main : k => v.arn
  }
}

# ============================================
# User Outputs
# ============================================

output "user_ids" {
  description = "Map of usernames to their user IDs"
  value = {
    for k, v in aws_connect_user.main : k => v.user_id
  }
}

output "user_arns" {
  description = "Map of usernames to their ARNs"
  value = {
    for k, v in aws_connect_user.main : k => v.arn
  }
}

output "admin_user_id" {
  description = "The ID of the admin user (if created)"
  value       = var.create_admin_user ? aws_connect_user.admin[0].user_id : null
}

output "admin_user_arn" {
  description = "The ARN of the admin user (if created)"
  value       = var.create_admin_user ? aws_connect_user.admin[0].arn : null
}

# ============================================
# User Hierarchy Group Outputs
# ============================================

output "hierarchy_group_ids" {
  description = "Map of hierarchy group names to their IDs"
  value = {
    for k, v in aws_connect_user_hierarchy_group.main : k => v.hierarchy_group_id
  }
}

output "hierarchy_group_arns" {
  description = "Map of hierarchy group names to their ARNs"
  value = {
    for k, v in aws_connect_user_hierarchy_group.main : k => v.hierarchy_group_arn
  }
}

# ============================================
# Lambda Association Outputs
# ============================================

output "lambda_function_associations" {
  description = "Map of Lambda function associations"
  value = {
    for k, v in aws_connect_lambda_function_association.main : k => {
      function_arn = v.function_arn
    }
  }
}

# ============================================
# Lex Bot Association Outputs
# ============================================

output "lex_bot_associations" {
  description = "Map of Lex bot associations"
  value = {
    for k, v in aws_connect_bot_association.main : k => {
      name       = v.lex_bot[0].name
      lex_region = v.lex_bot[0].lex_region
    }
  }
}

# ============================================
# Summary Output
# ============================================

output "connect_summary" {
  description = "Summary of the Connect instance configuration"
  value = {
    instance_id           = aws_connect_instance.main.id
    instance_arn          = aws_connect_instance.main.arn
    instance_alias        = aws_connect_instance.main.instance_alias
    instance_status       = aws_connect_instance.main.status
    hours_of_operation    = length(aws_connect_hours_of_operation.main)
    queues                = length(aws_connect_queue.main)
    routing_profiles      = length(aws_connect_routing_profile.main)
    security_profiles     = length(aws_connect_security_profile.main)
    quick_connects        = length(aws_connect_quick_connect.main)
    phone_numbers         = length(aws_connect_phone_number.main)
    contact_flows         = length(aws_connect_contact_flow.main)
    users                 = length(aws_connect_user.main)
    admin_user_created    = var.create_admin_user
    lambda_associations   = length(aws_connect_lambda_function_association.main)
    lex_bot_associations  = length(aws_connect_bot_association.main)
  }
}
