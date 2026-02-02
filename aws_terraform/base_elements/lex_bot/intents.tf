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

  dynamic "confirmation_setting" {
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

  dynamic "closing_setting" {
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
