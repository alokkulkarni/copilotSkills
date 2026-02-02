terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# CloudWatch Log Group for conversation logs
resource "aws_cloudwatch_log_group" "lex_bot_logs" {
  name              = "/aws/lex/${var.bot_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Lex Bot Module
module "customer_service_bot" {
  source = "../../"

  bot_name                    = var.bot_name
  description                 = "Simple customer service chatbot"
  idle_session_ttl_in_seconds = 300

  bot_locales = {
    "en_GB" = {
      description              = "English (GB)"
      nlu_confidence_threshold = 0.4
      voice_id                 = "Amy"
      voice_engine             = "neural"
    }
  }

  intents = {
    "Greeting" = {
      locale_id = "en_GB"
      description = "Greet the user"
      sample_utterances = [
        "hello",
        "hi",
        "hey",
        "good morning",
        "good afternoon"
      ]
      closing_message = "Hello! How can I help you today?"
    }

    "Help" = {
      locale_id = "en_GB"
      description = "Provide help"
      sample_utterances = [
        "help",
        "I need help",
        "what can you do"
      ]
      closing_message = "I can help with account info and order status. What do you need?"
      enable_dialog_code_hook = true  # Enable dialog hook for dynamic responses
    }

    "Goodbye" = {
      locale_id = "en_GB"
      description = "End conversation"
      sample_utterances = [
        "bye",
        "goodbye",
        "thank you"
      ]
      closing_message = "Thank you for contacting us. Have a great day!"
    }
  }

  create_version      = true
  version_description = "v1.0.0 - Initial release"

  bot_aliases = {
    "production" = {
      description = "Production alias"
      locale_settings = {
        "en_GB" = { enabled = true }
      }
      enable_conversation_logs  = true
      text_log_group_arn        = aws_cloudwatch_log_group.lex_bot_logs.arn
      enable_sentiment_analysis = true
    }
  }

  create_role              = true
  attach_cloudwatch_policy = true

  tags = {
    Environment = var.environment
    Application = "customer-service"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "bot_id" {
  value = module.customer_service_bot.bot_id
}

output "bot_arn" {
  value = module.customer_service_bot.bot_arn
}

output "production_alias_id" {
  value = module.customer_service_bot.alias_ids["production"]
}

output "bot_summary" {
  value = module.customer_service_bot.summary
}

output "test_command" {
  description = "Command to test the bot"
  value = <<-EOT
    aws lexv2-runtime recognize-text \
      --bot-id ${module.customer_service_bot.bot_id} \
      --bot-alias-id ${module.customer_service_bot.alias_ids["production"]} \
      --locale-id en_GB \
      --session-id test-123 \
      --text "Hello" \
      --region ${var.aws_region}
  EOT
}
