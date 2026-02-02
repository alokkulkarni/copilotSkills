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

output "production_alias_id" {
  description = "Production alias ID"
  value       = module.booking_bot.alias_ids["production"]
}

# ================================
# Lambda Outputs
# ================================

output "lambda_function_name" {
  description = "Name of the fulfillment Lambda function"
  value       = module.booking_fulfillment.function_name
}

output "lambda_function_arn" {
  description = "ARN of the fulfillment Lambda function"
  value       = module.booking_fulfillment.function_arn
}

# ================================
# Integration Outputs
# ================================

output "bot_summary" {
  description = "Summary of the deployed bot"
  value       = module.booking_bot.summary
}

output "test_command" {
  description = "AWS CLI command to test the bot"
  value = <<-EOT
    aws lexv2-runtime recognize-text \
      --bot-id ${module.booking_bot.bot_id} \
      --bot-alias-id ${module.booking_bot.alias_ids["production"]} \
      --locale-id en_GB \
      --session-id test-session-001 \
      --text "I want to book a room" \
      --region ${var.aws_region}
  EOT
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for Lex bot"
  value       = aws_cloudwatch_log_group.lex_logs.name
}
