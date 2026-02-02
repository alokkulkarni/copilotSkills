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

output "queue_id" {
  description = "The ID of the BasicQueue"
  value       = module.connect.queue_ids["BasicQueue"]
}

output "routing_profile_id" {
  description = "The ID of the BasicAgentProfile"
  value       = module.connect.routing_profile_ids["BasicAgentProfile"]
}

output "security_profile_id" {
  description = "The ID of the BasicAgentAccess profile"
  value       = module.connect.security_profile_ids["BasicAgentAccess"]
}

output "test_user_id" {
  description = "The ID of the test agent user"
  value       = module.connect.user_ids[var.test_user_username]
}

output "connect_summary" {
  description = "Summary of the Connect instance deployment"
  value       = module.connect.connect_summary
}

output "connect_console_url" {
  description = "URL to access the Connect instance console"
  value       = "https://${module.connect.instance_alias}.my.connect.aws/"
}
