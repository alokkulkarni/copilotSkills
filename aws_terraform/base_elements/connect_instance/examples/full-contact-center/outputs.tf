# ============================================
# Instance Outputs
# ============================================

output "connect_instance_id" {
  description = "The ID of the Connect instance"
  value       = module.connect.instance_id
}

output "connect_instance_arn" {
  description = "The ARN of the Connect instance"
  value       = module.connect.instance_arn
}

output "connect_instance_status" {
  description = "The status of the Connect instance"
  value       = module.connect.instance_status
}

output "connect_console_url" {
  description = "URL to access the Connect instance console"
  value       = "https://${module.connect.instance_alias}.my.connect.aws/"
}

# ============================================
# Phone Number Outputs
# ============================================

output "phone_numbers" {
  description = "Provisioned phone numbers"
  value       = module.connect.phone_numbers
}

output "phone_number_arns" {
  description = "ARNs of provisioned phone numbers"
  value       = module.connect.phone_number_arns
}

# ============================================
# Queue Outputs
# ============================================

output "sales_queue_id" {
  description = "The ID of the Sales Queue"
  value       = module.connect.queue_ids["SalesQueue"]
}

output "support_queue_id" {
  description = "The ID of the Support Queue"
  value       = module.connect.queue_ids["SupportQueue"]
}

output "queue_arns" {
  description = "ARNs of all queues"
  value       = module.connect.queue_arns
}

# ============================================
# Routing Profile Outputs
# ============================================

output "routing_profile_ids" {
  description = "Map of routing profile names to IDs"
  value       = module.connect.routing_profile_ids
}

output "routing_profile_arns" {
  description = "Map of routing profile names to ARNs"
  value       = module.connect.routing_profile_arns
}

# ============================================
# Security Profile Outputs
# ============================================

output "security_profile_ids" {
  description = "Map of security profile names to IDs"
  value       = module.connect.security_profile_ids
}

output "security_profile_arns" {
  description = "Map of security profile names to ARNs"
  value       = module.connect.security_profile_arns
}

# ============================================
# User Outputs
# ============================================

output "user_ids" {
  description = "Map of usernames to user IDs"
  value       = module.connect.user_ids
}

output "admin_user_id" {
  description = "The ID of the admin user (if created)"
  value       = module.connect.admin_user_id
}

output "hierarchy_group_ids" {
  description = "Map of hierarchy group names to IDs"
  value       = module.connect.hierarchy_group_ids
}

# ============================================
# Contact Flow Outputs
# ============================================

output "contact_flow_ids" {
  description = "Map of contact flow names to IDs"
  value       = module.connect.contact_flow_ids
}

output "contact_flow_arns" {
  description = "Map of contact flow names to ARNs"
  value       = module.connect.contact_flow_arns
}

# ============================================
# Quick Connect Outputs
# ============================================

output "quick_connect_ids" {
  description = "Map of quick connect keys to IDs"
  value       = module.connect.quick_connect_ids
}

# ============================================
# Summary Output
# ============================================

output "deployment_summary" {
  description = "Complete summary of the Connect deployment"
  value       = module.connect.connect_summary
}

output "user_summary" {
  description = "Summary of created users by role"
  value = {
    sales_users = [
      "sales.supervisor",
      "sales.agent1",
      "sales.agent2"
    ]
    support_users = [
      "support.supervisor",
      "support.agent1",
      "support.agent2"
    ]
    admin_created = var.create_admin_user
    total_users   = 6 + (var.create_admin_user ? 1 : 0)
  }
}

output "next_steps" {
  description = "Next steps after deployment"
  value = <<-EOT
    
    ========================================
    AWS Connect Instance Successfully Deployed!
    ========================================
    
    Console URL: https://${module.connect.instance_alias}.my.connect.aws/
    
    Next Steps:
    1. Access the Connect console using the URL above
    2. Set passwords for users or configure SSO
    3. Test the main inbound contact flow
    4. Configure additional contact flows as needed
    5. Review CloudWatch logs for contact flow execution
    ${var.provision_phone_numbers ? "6. Test calling the provisioned phone numbers" : "6. Claim phone numbers in the Connect console"}
    ${var.enable_contact_lens ? "7. Review Contact Lens analytics dashboard" : ""}
    
    Users Created:
    - Admin: ${var.create_admin_user ? "admin" : "none"}
    - Sales: sales.supervisor, sales.agent1, sales.agent2
    - Support: support.supervisor, support.agent1, support.agent2
    
    Queues:
    - SalesQueue (Business Hours: Mon-Fri, 9 AM - 5 PM)
    - SupportQueue (Extended Hours: Mon-Sat, 8 AM - 8 PM)
    
    ========================================
  EOT
}
