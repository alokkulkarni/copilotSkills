# ============================================
# AWS Connect Instance - Core Resource
# ============================================
# Create the main Amazon Connect instance with specified configuration
# This is the core resource that all other Connect components depend on
#
# Related resources are organized in separate files:
# - iam.tf: IAM roles and policies
# - logging.tf: CloudWatch log groups
# - hours_of_operation.tf: Business hours configuration
# - queues.tf: Queue resources
# - routing_profiles.tf: Agent routing configuration
# - security_profiles.tf: User permissions
# - quick_connects.tf: Transfer destinations
# - phone_numbers.tf: Phone number provisioning
# - contact_flows.tf: Call flow logic
# - users.tf: User and hierarchy management
# - integrations.tf: Lambda and Lex bot associations

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
