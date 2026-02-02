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
# Queue Outputs
# ============================================

output "queue_id" {
  description = "The ID of the AI Escalation Queue"
  value       = module.connect.queue_ids["AIEscalationQueue"]
}

output "queue_arn" {
  description = "The ARN of the AI Escalation Queue"
  value       = module.connect.queue_arns["AIEscalationQueue"]
}

# ============================================
# Routing Profile Outputs
# ============================================

output "routing_profile_ids" {
  description = "Map of routing profile names to IDs"
  value       = module.connect.routing_profile_ids
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

# ============================================
# Contact Flow Outputs
# ============================================

output "contact_flow_id" {
  description = "The ID of the Lex Lambda contact flow"
  value       = module.connect.contact_flow_ids["LexLambdaFlow"]
}

output "contact_flow_arn" {
  description = "The ARN of the Lex Lambda contact flow"
  value       = module.connect.contact_flow_arns["LexLambdaFlow"]
}

# ============================================
# Integration Outputs
# ============================================

output "lambda_function_associations" {
  description = "Lambda function associations"
  value       = module.connect.lambda_function_associations
}

output "lex_bot_associations" {
  description = "Lex bot associations"
  value       = module.connect.lex_bot_associations
}

# ============================================
# Summary Output
# ============================================

output "deployment_summary" {
  description = "Summary of the Connect deployment"
  value       = module.connect.connect_summary
}

output "integration_summary" {
  description = "Summary of AI integrations"
  value = {
    lex_bot_configured    = var.lex_bot_name != ""
    lex_bot_name          = var.lex_bot_name
    lambda_configured     = var.lambda_arn != ""
    lambda_arn            = var.lambda_arn
    contact_flow_deployed = true
  }
}

output "next_steps" {
  description = "Next steps after deployment"
  value = <<-EOT
    
    ========================================
    AWS Connect with AI Integration Deployed!
    ========================================
    
    Console URL: https://${module.connect.instance_alias}.my.connect.aws/
    
    Integration Status:
    - Lex Bot: ${var.lex_bot_name != "" ? "✓ Configured (${var.lex_bot_name})" : "✗ Not configured"}
    - Lambda: ${var.lambda_arn != "" ? "✓ Configured" : "✗ Not configured"}
    - Contact Flow: ✓ Deployed (LexLambdaFlow)
    
    Next Steps:
    
    ${var.lex_bot_name == "" ? "1. Deploy a Lex bot using the ../../../lex_bot module" : ""}
    ${var.lambda_arn == "" ? "2. Deploy a Lambda function using the ../../../lambda_function module" : ""}
    ${var.lex_bot_name == "" || var.lambda_arn == "" ? "3. Update terraform.tfvars with Lex bot name and Lambda ARN" : ""}
    ${var.lex_bot_name == "" || var.lambda_arn == "" ? "4. Run terraform apply again to associate integrations" : ""}
    
    Configuration:
    5. Set contact attributes in the contact flow:
       - LexBotName: ${var.lex_bot_name}
       - LexBotRegion: ${var.lex_region != "" ? var.lex_region : var.aws_region}
       - LexBotAlias: ${var.lex_bot_alias}
       - LambdaFunctionARN: ${var.lambda_arn}
       - QueueId: ${length(module.connect.queue_ids) > 0 ? module.connect.queue_ids["AIEscalationQueue"] : ""}
    
    6. Claim a phone number in Connect console
    7. Assign the LexLambdaFlow to the phone number
    8. Test the integration by calling the number
    
    Testing:
    - Speak naturally when prompted
    - Verify Lex correctly identifies intent
    - Check Lambda is invoked with correct parameters
    - Confirm routing works (self-service vs agent transfer)
    
    Monitoring:
    - CloudWatch Logs: /aws/connect/${module.connect.instance_alias}
    - Lambda Logs: CloudWatch Logs for your function
    - Lex Analytics: Lex console conversation logs
    
    Users Created:
    - Admin: ${var.create_admin_user ? "admin" : "none"}
    - Supervisor: supervisor
    - Agents: agent1, agent2
    
    ========================================
  EOT
}
