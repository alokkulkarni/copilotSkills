# ================================
# AWS Lex Bot Resources
# ================================
# Creates and configures AWS Lex V2 bot with intents, slots, and aliases
# Related components are in separate files:
# - iam.tf: IAM roles and policies
# - intents.tf: Bot intents and conversation flows
# - slots.tf: Slot definitions and custom slot types
# - versions_and_aliases.tf: Bot versions and aliases

# ================================
# Lex Bot
# ================================
resource "aws_lexv2models_bot" "this" {
  name                        = var.bot_name
  description                 = var.description
  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds
  role_arn                    = var.create_role ? aws_iam_role.lex_bot[0].arn : var.role_arn

  data_privacy {
    child_directed = var.child_directed
  }

  dynamic "members" {
    for_each = var.bot_members
    content {
      alias_id   = members.value.alias_id
      alias_name = members.value.alias_name
      id         = members.value.id
      name       = members.value.name
      version    = members.value.version
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      data_privacy[0].child_directed
    ]
  }
}

# ================================
# Lex Bot Locale
# ================================
resource "aws_lexv2models_bot_locale" "this" {
  for_each = var.bot_locales

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = "DRAFT"
  locale_id   = each.key
  description = each.value.description

  n_lu_intent_confidence_threshold = each.value.nlu_confidence_threshold

  dynamic "voice_settings" {
    for_each = each.value.voice_id != null ? [1] : []
    content {
      voice_id = each.value.voice_id
      engine   = each.value.voice_engine
    }
  }

  depends_on = [aws_lexv2models_bot.this]
}
