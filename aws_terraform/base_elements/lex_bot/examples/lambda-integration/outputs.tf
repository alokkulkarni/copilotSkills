# ================================
# Bot Outputs
# ================================

output "bot_id" {
  description = "ID of the Lex bot"
  value       = module.booking_bot.bot_id
}

output "bot_arn" {
  description = "ARN of the Lex bot"
  value       = module.booking_bot.bot_arn
}

output "bot_name" {
  description = "Name of the bot"
  value       = module.booking_bot.bot_name
}

# ================================
# Alias Outputs
# ================================

output "production_alias_id" {
  description = "Production alias ID"
  value       = module.booking_bot.alias_ids["production"]
}

output "staging_alias_id" {
  description = "Staging alias ID"
  value       = module.booking_bot.alias_ids["staging"]
}

# ================================
# Lambda Outputs
# ================================

output "dialog_hook_function_name" {
  description = "Name of the dialog hook Lambda function"
  value       = module.dialog_hook.function_name
}

output "dialog_hook_function_arn" {
  description = "ARN of the dialog hook Lambda function"
  value       = module.dialog_hook.function_arn
}

output "fulfillment_hook_function_name" {
  description = "Name of the fulfillment hook Lambda function"
  value       = module.fulfillment_hook.function_name
}

output "fulfillment_hook_function_arn" {
  description = "ARN of the fulfillment hook Lambda function"
  value       = module.fulfillment_hook.function_arn
}

# ================================
# Integration Outputs
# ================================

output "bot_summary" {
  description = "Summary of the deployed bot"
  value       = module.booking_bot.summary
}

output "test_booking_command" {
  description = "AWS CLI command to test room booking"
  value = <<-EOT
    aws lexv2-runtime recognize-text \
      --bot-id ${module.booking_bot.bot_id} \
      --bot-alias-id ${module.booking_bot.alias_ids["production"]} \
      --locale-id en_GB \
      --session-id test-session-${formatdate("YYYYMMDDhhmmss", timestamp())} \
      --text "I want to book a room" \
      --region ${var.aws_region}
  EOT
}

output "test_cancellation_command" {
  description = "AWS CLI command to test booking cancellation"
  value = <<-EOT
    aws lexv2-runtime recognize-text \
      --bot-id ${module.booking_bot.bot_id} \
      --bot-alias-id ${module.booking_bot.alias_ids["production"]} \
      --locale-id en_GB \
      --session-id test-session-${formatdate("YYYYMMDDhhmmss", timestamp())} \
      --text "Cancel booking ABC123" \
      --region ${var.aws_region}
  EOT
}

output "lambda_log_groups" {
  description = "CloudWatch log group names for Lambda functions"
  value = {
    dialog_hook      = "/aws/lambda/${module.dialog_hook.function_name}"
    fulfillment_hook = "/aws/lambda/${module.fulfillment_hook.function_name}"
    lex_bot          = aws_cloudwatch_log_group.lex_bot_logs.name
  }
}
