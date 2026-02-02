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
