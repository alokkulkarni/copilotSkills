# ================================
# AWS Lex Bot Resources
# ================================
# Creates and configures AWS Lex V2 bot with intents, slots, and aliases

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

# ================================
# Lex Bot Intents
# ================================
resource "aws_lexv2models_intent" "this" {
  for_each = var.intents

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = "DRAFT"
  locale_id   = each.value.locale_id
  name        = each.key
  description = each.value.description

  parent_intent_signature = each.value.parent_intent_signature

  dynamic "sample_utterance" {
    for_each = each.value.sample_utterances
    content {
      utterance = sample_utterance.value
    }
  }

  dynamic "slot_priority" {
    for_each = each.value.slot_priorities
    content {
      priority = slot_priority.value.priority
      slot_id  = slot_priority.value.slot_id
    }
  }

  dynamic "intent_confirmation_setting" {
    for_each = each.value.enable_confirmation ? [1] : []
    content {
      dynamic "prompt_specification" {
        for_each = each.value.confirmation_prompt != null ? [1] : []
        content {
          max_retries                  = each.value.confirmation_max_retries
          allow_interrupt              = each.value.confirmation_allow_interrupt
          message_selection_strategy   = "Random"

          dynamic "message_group" {
            for_each = [each.value.confirmation_prompt]
            content {
              message {
                plain_text_message {
                  value = message_group.value
                }
              }
            }
          }
        }
      }

      dynamic "declination_response" {
        for_each = each.value.declination_response != null ? [1] : []
        content {
          allow_interrupt = true

          message_group {
            message {
              plain_text_message {
                value = each.value.declination_response
              }
            }
          }
        }
      }
    }
  }

  dynamic "intent_closing_setting" {
    for_each = each.value.closing_message != null ? [1] : []
    content {
      closing_response {
        allow_interrupt = true

        message_group {
          message {
            plain_text_message {
              value = each.value.closing_message
            }
          }
        }
      }
    }
  }

  # Dialog code hook - invoked at each conversation turn
  dynamic "dialog_code_hook" {
    for_each = each.value.enable_dialog_code_hook ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "fulfillment_code_hook" {
    for_each = each.value.enable_fulfillment_code_hook ? [1] : []
    content {
      enabled = true
      
      dynamic "post_fulfillment_status_specification" {
        for_each = each.value.fulfillment_success_response != null || each.value.fulfillment_failure_response != null ? [1] : []
        content {
          dynamic "success_response" {
            for_each = each.value.fulfillment_success_response != null ? [1] : []
            content {
              allow_interrupt = true

              message_group {
                message {
                  plain_text_message {
                    value = each.value.fulfillment_success_response
                  }
                }
              }
            }
          }

          dynamic "failure_response" {
            for_each = each.value.fulfillment_failure_response != null ? [1] : []
            content {
              allow_interrupt = true

              message_group {
                message {
                  plain_text_message {
                    value = each.value.fulfillment_failure_response
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_lexv2models_bot_locale.this]
}

# ================================
# Lex Slots
# ================================
resource "aws_lexv2models_slot" "this" {
  for_each = var.slots

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = "DRAFT"
  intent_id   = aws_lexv2models_intent.this[each.value.intent_name].intent_id
  locale_id   = each.value.locale_id
  name        = each.key
  description = each.value.description

  slot_type_id = each.value.slot_type_id

  value_elicitation_setting {
    slot_constraint = each.value.is_required ? "Required" : "Optional"

    dynamic "prompt_specification" {
      for_each = each.value.is_required && each.value.prompt_message != null ? [1] : []
      content {
        max_retries                = each.value.prompt_max_retries
        allow_interrupt            = each.value.prompt_allow_interrupt
        message_selection_strategy = "Random"

        message_group {
          message {
            plain_text_message {
              value = each.value.prompt_message
            }
          }
        }
      }
    }

    dynamic "default_value_specification" {
      for_each = length(each.value.default_values) > 0 ? [1] : []
      content {
        dynamic "default_value_list" {
          for_each = each.value.default_values
          content {
            default_value = default_value_list.value
          }
        }
      }
    }
  }

  depends_on = [aws_lexv2models_intent.this]
}

# ================================
# Custom Slot Types
# ================================
resource "aws_lexv2models_slot_type" "this" {
  for_each = var.custom_slot_types

  bot_id      = aws_lexv2models_bot.this.id
  bot_version = "DRAFT"
  locale_id   = each.value.locale_id
  name        = each.key
  description = each.value.description

  dynamic "slot_type_values" {
    for_each = each.value.values
    content {
      sample_value {
        value = slot_type_values.value.value
      }

      dynamic "synonyms" {
        for_each = slot_type_values.value.synonyms
        content {
          value = synonyms.value
        }
      }
    }
  }

  dynamic "value_selection_setting" {
    for_each = [1]
    content {
      resolution_strategy = each.value.resolution_strategy

      dynamic "advanced_recognition_setting" {
        for_each = each.value.enable_advanced_recognition ? [1] : []
        content {
          audio_recognition_strategy = each.value.audio_recognition_strategy
        }
      }
    }
  }

  depends_on = [aws_lexv2models_bot_locale.this]
}

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

# ================================
# IAM Role for Lex Bot
# ================================
resource "aws_iam_role" "lex_bot" {
  count = var.create_role ? 1 : 0

  name        = "${var.bot_name}-role"
  description = "IAM role for Lex bot ${var.bot_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lex_bot_basic" {
  count = var.create_role ? 1 : 0

  name = "${var.bot_name}-basic-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "polly:SynthesizeSpeech",
          "comprehend:DetectSentiment"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Logs policy for Lex bot
# Note: Resource ARN uses wildcard for region (*) to support multi-region deployments
# Ensure IAM permissions are granted for the target deployment region (e.g., eu-west-2)
resource "aws_iam_role_policy" "lex_bot_cloudwatch" {
  count = var.create_role && var.attach_cloudwatch_policy ? 1 : 0

  name = "${var.bot_name}-cloudwatch-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lex/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lex_bot_s3" {
  count = var.create_role && var.attach_s3_policy ? 1 : 0

  name = "${var.bot_name}-s3-policy"
  role = aws_iam_role.lex_bot[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = var.s3_bucket_arn != null ? "${var.s3_bucket_arn}/*" : "*"
      }
    ]
  })
}

# ================================
# Data Sources
# ================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
