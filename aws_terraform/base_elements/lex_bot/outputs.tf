# ================================
# Bot Outputs
# ================================

output "bot_id" {
  description = "ID of the Lex bot"
  value       = aws_lexv2models_bot.this.id
}

output "bot_arn" {
  description = "ARN of the Lex bot"
  value       = aws_lexv2models_bot.this.arn
}

output "bot_name" {
  description = "Name of the Lex bot"
  value       = aws_lexv2models_bot.this.name
}

# ================================
# Locale Outputs
# ================================

output "locale_ids" {
  description = "Map of locale IDs"
  value       = { for k, v in aws_lexv2models_bot_locale.this : k => v.locale_id }
}

# ================================
# Intent Outputs
# ================================

output "intent_ids" {
  description = "Map of intent names to intent IDs"
  value       = { for k, v in aws_lexv2models_intent.this : k => v.intent_id }
}

output "intent_arns" {
  description = "Map of intent names to intent ARNs"
  value       = { for k, v in aws_lexv2models_intent.this : k => v.id }
}

# ================================
# Slot Outputs
# ================================

output "slot_ids" {
  description = "Map of slot names to slot IDs"
  value       = { for k, v in aws_lexv2models_slot.this : k => v.slot_id }
}

# ================================
# Custom Slot Type Outputs
# ================================

output "custom_slot_type_ids" {
  description = "Map of custom slot type names to slot type IDs"
  value       = { for k, v in aws_lexv2models_slot_type.this : k => v.slot_type_id }
}

# ================================
# Version Outputs
# ================================

output "bot_version" {
  description = "Version number of the bot"
  value       = var.create_version ? aws_lexv2models_bot_version.this[0].bot_version : null
}

output "bot_version_arn" {
  description = "ARN of the bot version"
  value       = var.create_version ? aws_lexv2models_bot_version.this[0].id : null
}

# ================================
# Alias Outputs
# ================================

output "alias_ids" {
  description = "Map of alias names to alias IDs"
  value       = { for k, v in aws_lexv2models_bot_alias.this : k => v.bot_alias_id }
}

output "alias_arns" {
  description = "Map of alias names to alias ARNs"
  value       = { for k, v in aws_lexv2models_bot_alias.this : k => v.arn }
}

output "alias_names" {
  description = "Map of configured alias names"
  value       = { for k, v in aws_lexv2models_bot_alias.this : k => v.bot_alias_name }
}

# ================================
# IAM Outputs
# ================================

output "role_arn" {
  description = "ARN of the IAM role used by the bot"
  value       = var.create_role ? aws_iam_role.lex_bot[0].arn : var.role_arn
}

output "role_name" {
  description = "Name of the IAM role used by the bot"
  value       = var.create_role ? aws_iam_role.lex_bot[0].name : null
}

# ================================
# Integration Outputs
# ================================

output "bot_endpoint" {
  description = "Endpoint information for integrating with the bot"
  value = {
    bot_id      = aws_lexv2models_bot.this.id
    bot_name    = aws_lexv2models_bot.this.name
    region      = data.aws_region.current.id
    alias_ids   = { for k, v in aws_lexv2models_bot_alias.this : k => v.bot_alias_id }
  }
}

# ================================
# Summary Output
# ================================

output "summary" {
  description = "Summary of the deployed Lex bot"
  value = {
    bot_id         = aws_lexv2models_bot.this.id
    bot_name       = aws_lexv2models_bot.this.name
    bot_arn        = aws_lexv2models_bot.this.arn
    locales        = keys(aws_lexv2models_bot_locale.this)
    intents_count  = length(aws_lexv2models_intent.this)
    slots_count    = length(aws_lexv2models_slot.this)
    aliases_count  = length(aws_lexv2models_bot_alias.this)
    version        = var.create_version ? aws_lexv2models_bot_version.this[0].bot_version : "DRAFT"
  }
}
