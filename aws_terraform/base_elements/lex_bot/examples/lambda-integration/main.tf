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
# Lambda Functions for Lex Hooks
# ============================================

# Archive Lambda code
data "archive_file" "dialog_hook" {
  type        = "zip"
  source_file = "${path.module}/lambda/dialog_hook.py"
  output_path = "${path.module}/.terraform/dialog_hook.zip"
}

data "archive_file" "fulfillment_hook" {
  type        = "zip"
  source_file = "${path.module}/lambda/fulfillment_hook.py"
  output_path = "${path.module}/.terraform/fulfillment_hook.zip"
}

# Lambda function for dialog hook (validation) using lambda_function module
module "dialog_hook" {
  source = "../../../lambda_function"

  function_name = "${var.bot_name}-dialog-hook"
  description   = "Dialog hook Lambda for slot validation"
  handler       = "dialog_hook.lambda_handler"
  runtime       = "python3.11"
  timeout       = 10
  memory_size   = 256

  filename         = data.archive_file.dialog_hook.output_path
  source_code_hash = data.archive_file.dialog_hook.output_base64sha256

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  create_role                  = true
  attach_cloudwatch_logs_policy = true

  tags = {
    Environment = var.environment
    Purpose     = "DialogHook"
    ManagedBy   = "Terraform"
  }
}

# Lambda function for fulfillment hook using lambda_function module
module "fulfillment_hook" {
  source = "../../../lambda_function"

  function_name = "${var.bot_name}-fulfillment-hook"
  description   = "Fulfillment hook Lambda for booking processing"
  handler       = "fulfillment_hook.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  filename         = data.archive_file.fulfillment_hook.output_path
  source_code_hash = data.archive_file.fulfillment_hook.output_base64sha256

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  create_role                  = true
  attach_cloudwatch_logs_policy = true

  tags = {
    Environment = var.environment
    Purpose     = "FulfillmentHook"
    ManagedBy   = "Terraform"
  }
}

# Lambda permissions for Lex to invoke
resource "aws_lambda_permission" "lex_invoke_dialog" {
  statement_id  = "AllowLexInvokeDialog"
  action        = "lambda:InvokeFunction"
  function_name = module.dialog_hook.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "${module.booking_bot.bot_arn}/*"
}

resource "aws_lambda_permission" "lex_invoke_fulfillment" {
  statement_id  = "AllowLexInvokeFulfillment"
  action        = "lambda:InvokeFunction"
  function_name = module.fulfillment_hook.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "${module.booking_bot.bot_arn}/*"
}

# ============================================
# CloudWatch Log Group for Bot Logs
# ============================================

resource "aws_cloudwatch_log_group" "lex_bot_logs" {
  name              = "/aws/lex/${var.bot_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================
# Lex Bot with Lambda Integration
# ============================================

module "booking_bot" {
  source = "../../"

  bot_name                    = var.bot_name
  description                 = "Hotel booking bot with dialog and fulfillment hooks"
  idle_session_ttl_in_seconds = 300

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
      description         = "Types of hotel rooms"
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
          synonyms = ["luxury suite", "executive suite"]
        }
      ]
    }
  }

  intents = {
    "BookRoom" = {
      locale_id   = "en_GB"
      description = "Book a hotel room with validation and fulfillment"
      sample_utterances = [
        "I want to book a room",
        "Book a {RoomType} room",
        "I need accommodation for {CheckInDate}",
        "Reserve a room for {Nights} nights"
      ]
      slot_priorities = [
        { priority = 1, slot_id = "RoomType" },
        { priority = 2, slot_id = "CheckInDate" },
        { priority = 3, slot_id = "Nights" }
      ]
      # Enable dialog hook for slot validation
      enable_dialog_code_hook = true
      # Enable confirmation
      enable_confirmation           = true
      confirmation_prompt           = "Would you like to book a {RoomType} room for {Nights} nights starting {CheckInDate}?"
      confirmation_max_retries      = 2
      confirmation_allow_interrupt  = true
      declination_response          = "Okay, I've cancelled your booking request."
      # Enable fulfillment hook for completing the booking
      enable_fulfillment_code_hook  = true
      fulfillment_success_response  = "Great! Your {RoomType} room has been booked for {Nights} nights starting {CheckInDate}. Confirmation number: {BookingNumber}"
      fulfillment_failure_response  = "Sorry, we couldn't complete your booking. Please try again or contact support."
      closing_message               = "Thank you for booking with us!"
    }

    "CancelBooking" = {
      locale_id   = "en_GB"
      description = "Cancel an existing booking"
      sample_utterances = [
        "Cancel my booking",
        "I want to cancel reservation {BookingNumber}",
        "Cancel booking number {BookingNumber}"
      ]
      slot_priorities = [
        { priority = 1, slot_id = "BookingNumber" }
      ]
      # Dialog hook for validation
      enable_dialog_code_hook = true
      # Fulfillment to process cancellation
      enable_fulfillment_code_hook = true
      fulfillment_success_response = "Your booking {BookingNumber} has been cancelled successfully."
      fulfillment_failure_response = "We couldn't cancel booking {BookingNumber}. Please verify the booking number."
    }

    "CheckAvailability" = {
      locale_id   = "en_GB"
      description = "Check room availability"
      sample_utterances = [
        "Check availability",
        "Are there any {RoomType} rooms available",
        "Do you have rooms for {CheckInDate}"
      ]
      # Only dialog hook to check availability dynamically
      enable_dialog_code_hook = true
      closing_message         = "Let me check that for you..."
    }
  }

  slots = {
    "RoomType" = {
      intent_name            = "BookRoom"
      locale_id              = "en_GB"
      description            = "Type of room to book"
      slot_type_id           = "RoomType"  # Reference to custom slot type
      is_required            = true
      prompt_message         = "What type of room would you like - single, double, or suite?"
      prompt_max_retries     = 2
      prompt_allow_interrupt = true
    }
    "CheckInDate" = {
      intent_name            = "BookRoom"
      locale_id              = "en_GB"
      description            = "Check-in date"
      slot_type_id           = "AMAZON.Date"
      is_required            = true
      prompt_message         = "When would you like to check in? (DD/MM/YYYY)"
      prompt_max_retries     = 2
      prompt_allow_interrupt = true
    }
    "Nights" = {
      intent_name            = "BookRoom"
      locale_id              = "en_GB"
      description            = "Number of nights"
      slot_type_id           = "AMAZON.Number"
      is_required            = true
      prompt_message         = "How many nights will you be staying?"
      prompt_max_retries     = 2
      prompt_allow_interrupt = true
      default_values         = ["1"]
    }
    "BookingNumber" = {
      intent_name     = "CancelBooking"
      locale_id       = "en_GB"
      description     = "Booking confirmation number"
      slot_type_id    = "AMAZON.AlphaNumeric"
      is_required     = true
      prompt_message  = "What is your booking confirmation number?"
      prompt_max_retries = 2
    }
  }

  create_version      = true
  version_description = "v1.0.0 - Lambda integration with dialog and fulfillment hooks"

  # Production alias with Lambda configuration
  bot_aliases = {
    "production" = {
      description = "Production environment with Lambda integration"
      locale_settings = {
        "en_GB" = {
          enabled    = true
          lambda_arn = aws_lambda_function.fulfillment_hook.arn
        }
      }
      enable_conversation_logs  = true
      text_log_group_arn        = aws_cloudwatch_log_group.lex_bot_logs.arn
      enable_sentiment_analysis = true
    }
    "staging" = {
      description = "Staging environment for testing"
      locale_settings = {
        "en_GB" = {
          enabled    = true
          lambda_arn = module.fulfillment_hook.function_arn
        }
      }
      enable_conversation_logs  = true
      text_log_group_arn        = aws_cloudwatch_log_group.lex_bot_logs.arn
      enable_sentiment_analysis = false
    }
  }

  create_role              = true
  attach_cloudwatch_policy = true

  tags = {
    Environment = var.environment
    Application = "hotel-booking"
    Example     = "lambda-integration"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.dialog_hook,
    module.fulfillment_hook
  ]
}
