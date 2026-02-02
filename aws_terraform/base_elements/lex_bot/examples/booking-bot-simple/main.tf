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

# ============================================
# Lambda Function for Fulfillment
# ============================================

# Archive Lambda code
data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/booking_fulfillment.py"
  output_path = "${path.module}/.terraform/booking_fulfillment.zip"
}

# Lambda function using lambda_function module
module "booking_fulfillment" {
  source = "../../../lambda_function"

  function_name = "${var.bot_name}-fulfillment"
  description   = "Fulfillment Lambda for hotel booking bot"
  handler       = "booking_fulfillment.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  create_role                  = true
  attach_cloudwatch_logs_policy = true

  tags = {
    Environment = var.environment
    Purpose     = "BookingFulfillment"
    ManagedBy   = "Terraform"
  }
}

# Lambda permission for Lex to invoke
resource "aws_lambda_permission" "lex_invoke" {
  statement_id  = "AllowLexInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.booking_fulfillment.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "${module.booking_bot.bot_arn}/*"
}

# ============================================
# CloudWatch Log Group
# ============================================

resource "aws_cloudwatch_log_group" "lex_logs" {
  name              = "/aws/lex/${var.bot_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Lex Bot Module
# ============================================

module "booking_bot" {
  source = "../../"

  bot_name    = var.bot_name
  description = "Hotel room booking assistant"

  bot_locales = {
    "en_GB" = {
      description              = "English (GB)"
      nlu_confidence_threshold = 0.5
      voice_id                 = "Amy"
      voice_engine             = "neural"
    }
  }

  # Custom slot type for room types
  custom_slot_types = {
    "RoomType" = {
      locale_id           = "en_GB"
      description         = "Types of hotel rooms available"
      resolution_strategy = "TopResolution"
      values = [
        {
          value    = "single"
          synonyms = ["single room", "one bed", "solo"]
        },
        {
          value    = "double"
          synonyms = ["double room", "two beds", "twin"]
        },
        {
          value    = "suite"
          synonyms = ["luxury suite", "executive suite", "presidential"]
        }
      ]
    }
  }

  # Intent with slots
  intents = {
    "BookRoom" = {
      locale_id   = "en_GB"
      description = "Book a hotel room"
      sample_utterances = [
        "I want to book a room",
        "Book a {RoomType} room",
        "Reserve accommodation for {CheckInDate}",
        "I need a place to stay"
      ]
      slot_priorities = [
        { priority = 1, slot_id = "RoomType" },
        { priority = 2, slot_id = "CheckInDate" },
        { priority = 3, slot_id = "Nights" }
      ]
      enable_dialog_code_hook       = true
      enable_confirmation           = true
      confirmation_prompt           = "Would you like to book a {RoomType} room for {Nights} nights starting {CheckInDate}?"
      declination_response          = "Okay, I've cancelled your booking request."
      closing_message               = "Great! Your room has been booked successfully."
      enable_fulfillment_code_hook  = true
      fulfillment_success_response  = "Your booking is confirmed! Confirmation number: {BookingNumber}"
      fulfillment_failure_response  = "Sorry, we couldn't complete your booking. Please try again."
    }
  }

  # Slots for the booking intent
  slots = {
    "RoomType" = {
      intent_name            = "BookRoom"
      locale_id              = "en_GB"
      description            = "Type of room to book"
      slot_type_id           = "RoomType"  # Reference custom slot type
      is_required            = true
      prompt_message         = "What type of room would you like - single, double, or suite?"
      prompt_max_retries     = 2
      prompt_allow_interrupt = true
    }
    "CheckInDate" = {
      intent_name     = "BookRoom"
      locale_id       = "en_GB"
      description     = "Check-in date"
      slot_type_id    = "AMAZON.Date"
      is_required     = true
      prompt_message  = "When would you like to check in?"
    }
    "Nights" = {
      intent_name     = "BookRoom"
      locale_id       = "en_GB"
      description     = "Number of nights"
      slot_type_id    = "AMAZON.Number"
      is_required     = true
      prompt_message  = "How many nights will you be staying?"
      default_values  = ["1"]
    }
  }

  # Create version for production
  create_version      = true
  version_description = "v1.0 - Initial release"

  # Production alias with Lambda integration
  bot_aliases = {
    "production" = {
      description = "Production environment"
      locale_settings = {
        "en_GB" = {
          enabled    = true
          lambda_arn = module.booking_fulfillment.function_arn
        }
      }
      enable_conversation_logs  = true
      text_log_group_arn        = aws_cloudwatch_log_group.lex_logs.arn
      enable_sentiment_analysis = true
    }
  }

  create_role              = true
  attach_cloudwatch_policy = true

  tags = {
    Environment = var.environment
    Application = "hotel-booking"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.booking_fulfillment
  ]
}
