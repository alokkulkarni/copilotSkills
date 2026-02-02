# ================================
# Bot Version
# ================================

resource "aws_lexv2models_bot_version" "this" {
  count = var.create_version ? 1 : 0

  bot_id      = aws_lexv2models_bot.this.id
  description = var.version_description

  locale_specification = {
    for locale_id in keys(var.bot_locales) : locale_id => {
      source_bot_version = "DRAFT"
    }
  }

  depends_on = [
    aws_lexv2models_intent.this,
    aws_lexv2models_slot.this,
    aws_lexv2models_slot_type.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ================================
# Bot Alias
# ================================

resource "aws_lexv2models_bot_alias" "this" {
  for_each = var.bot_aliases

  bot_id      = aws_lexv2models_bot.this.id
  bot_alias_name = each.key
  description    = each.value.description
  bot_version    = each.value.bot_version != null ? each.value.bot_version : (var.create_version ? aws_lexv2models_bot_version.this[0].bot_version : null)

  dynamic "bot_alias_locale_settings" {
    for_each = each.value.locale_settings
    content {
      locale_id = bot_alias_locale_settings.key
      enabled   = bot_alias_locale_settings.value.enabled

      dynamic "code_hook_specification" {
        for_each = bot_alias_locale_settings.value.lambda_arn != null ? [1] : []
        content {
          lambda_code_hook {
            lambda_arn             = bot_alias_locale_settings.value.lambda_arn
            code_hook_interface_version = "1.0"
          }
        }
      }
    }
  }

  dynamic "conversation_log_settings" {
    for_each = each.value.enable_conversation_logs ? [1] : []
    content {
      dynamic "text_log_settings" {
        for_each = each.value.text_log_group_arn != null ? [1] : []
        content {
          enabled = true
          destination {
            cloudwatch {
              log_group_arn  = each.value.text_log_group_arn
              cloudwatch_log_group_arn = each.value.text_log_group_arn
            }
          }
        }
      }

      dynamic "audio_log_settings" {
        for_each = each.value.audio_log_s3_bucket != null ? [1] : []
        content {
          enabled = true
          destination {
            s3_bucket {
              s3_bucket_arn = each.value.audio_log_s3_bucket
              log_prefix    = each.value.audio_log_prefix
            }
          }
        }
      }
    }
  }

  dynamic "sentiment_analysis_settings" {
    for_each = each.value.enable_sentiment_analysis ? [1] : []
    content {
      detect_sentiment = true
    }
  }

  tags = var.tags

  depends_on = [aws_lexv2models_bot_version.this]
}
