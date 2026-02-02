# AWS Lex Bot Terraform Module

Production-ready Terraform module for deploying AWS Lex V2 conversational bots with complete configuration management.

## Quick Start Command Reference

### Most Common Operations

```bash
# Initialize with S3 backend
terraform init

# Plan/Apply specific components
terraform apply -target=module.lex_bot.aws_lexv2models_bot.this                    # Bot only
terraform apply -target=module.lex_bot.aws_lexv2models_intent.this                 # Intents only
terraform apply -target=module.lex_bot.aws_lexv2models_slot.this                   # Slots only
terraform apply -target=module.lex_bot.aws_lexv2models_bot_alias.this              # Aliases only

# Verify state
terraform state list                                                              # List all resources
terraform state show 'module.lex_bot.aws_lexv2models_bot.this'                    # Show bot details

# Check S3 state
aws s3 ls s3://my-terraform-state-bucket/lex-bot/                                 # List state files
```

**📘 For detailed command reference, see [Terraform Commands and State Management](#terraform-commands-and-state-management) section below.**  
**📕 For step-by-step operational procedures, see [OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md).**  
**📗 For complete S3 state management guide, see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md).**

## Table of Contents

- [Module Structure](#module-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- **[📘 Terraform Commands and State Management](#terraform-commands-and-state-management)** ⭐
- **[📋 Module-Level vs Component-Level Operations](#module-level-vs-component-level-operations)** ⭐
- [Usage](#usage)
- [Examples](#examples)
- [Best Practices](#best-practices)

### 📚 Additional Documentation

- **[OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md)** - Step-by-step procedures for common operational tasks
- **[STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)** - Complete guide for S3 state backend setup and management

## Module Structure

The module is organized into separate, focused files for better maintainability:

```
lex_bot/
├── main.tf                    # Core bot and locale resources
├── iam.tf                     # IAM roles and policies
├── intents.tf                 # Intent definitions and configurations
├── slots.tf                   # Slot and slot type definitions
├── versions_and_aliases.tf    # Bot versions and aliases
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider version constraints
└── README.md                  # This file
```

### Benefits of Modular Structure

- **Focused Changes**: Update intents without touching slots or aliases
- **Clear Separation**: Each file has a single, well-defined responsibility
- **Easy Navigation**: Quickly locate resources by category
- **Independent Testing**: Test specific components in isolation
- **Team Collaboration**: Multiple team members can work on different components

## Features

- ✅ **Complete Lex V2 Bot Management** - Full bot lifecycle from creation to deployment
- ✅ **Multi-Locale Support** - Configure multiple languages and regional variants
- ✅ **Intent Management** - Define conversational intents with sample utterances
- ✅ **Slot Configuration** - Create and manage slots with validation and prompts
- ✅ **Custom Slot Types** - Define custom slot types with synonyms and resolution strategies
- ✅ **Version Management** - Create immutable bot versions for production
- ✅ **Alias Support** - Route traffic to specific versions with aliases
- ✅ **Lambda Integration** - Connect to Lambda functions for fulfillment and dialog hooks
- ✅ **Dialog Code Hook** - Invoke Lambda at each conversation turn for validation and logic
- ✅ **Conversation Logs** - CloudWatch text logs and S3 audio logs
- ✅ **Sentiment Analysis** - Detect sentiment in conversations
- ✅ **IAM Role Management** - Automatic role creation with appropriate permissions
- ✅ **Voice Configuration** - Amazon Polly voice settings for responses

## Usage

### Basic Bot

```hcl
module "simple_bot" {
  source = "./base_elements/lex_bot"

  bot_name    = "MySimpleBot"
  description = "A simple customer service bot"

  bot_locales = {
    "en_GB" = {
      description              = "English (GB)"
      nlu_confidence_threshold = 0.4
    }
  }

  intents = {
    "Greeting" = {
      locale_id = "en_GB"
      sample_utterances = ["hello", "hi", "hey"]
      closing_message = "Hello! How can I help you?"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Bot with Custom Slots and Lambda Integration

```hcl
module "booking_bot" {
  source = "./base_elements/lex_bot"

  bot_name = "HotelBookingBot"
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
      locale_id = "en_GB"
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
      enable_dialog_code_hook = true
      enable_confirmation = true
      confirmation_prompt = "Would you like to book a {RoomType} room for {Nights} nights starting {CheckInDate}?"
      declination_response = "Okay, I've cancelled your booking request."
      closing_message = "Great! Your room has been booked successfully."
      enable_fulfillment_code_hook = true
      fulfillment_success_response = "Your booking is confirmed! Confirmation number: {BookingNumber}"
      fulfillment_failure_response = "Sorry, we couldn't complete your booking. Please try again."
    }
  }

  # Slots for the booking intent
  slots = {
    "RoomType" = {
      intent_name            = "BookRoom"
      locale_id              = "en_GB"
      description            = "Type of room to book"
      slot_type_id           = "AMAZON.AlphaNumeric"
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
  create_version = true
  version_description = "v1.0 - Initial release"

  # Production alias with Lambda integration
  bot_aliases = {
    "production" = {
      description = "Production environment"
      locale_settings = {
        "en_GB" = {
          enabled    = true
          lambda_arn = aws_lambda_function.booking_fulfillment.arn
        }
      }
      enable_conversation_logs = true
      text_log_group_arn = aws_cloudwatch_log_group.lex_logs.arn
      enable_sentiment_analysis = true
    }
  }

  create_role = true
  attach_cloudwatch_policy = true

  tags = {
    Environment = "production"
    Application = "hotel-booking"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Resources

| Type | Description |
|------|-------------|
| `aws_lexv2models_bot` | Main Lex bot resource |
| `aws_lexv2models_bot_locale` | Locale configurations for the bot |
| `aws_lexv2models_intent` | Conversational intents |
| `aws_lexv2models_slot` | Slot definitions for intents |
| `aws_lexv2models_slot_type` | Custom slot type definitions |
| `aws_lexv2models_bot_version` | Immutable bot version |
| `aws_lexv2models_bot_alias` | Alias pointing to bot version |
| `aws_iam_role` | IAM role for bot execution |
| `aws_iam_role_policy` | IAM policies for bot permissions |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bot_name | Name of the Lex bot | `string` | n/a | yes |
| description | Bot description | `string` | `""` | no |
| idle_session_ttl_in_seconds | Session idle timeout (60-86400) | `number` | `300` | no |
| child_directed | COPPA compliance flag | `bool` | `false` | no |
| bot_locales | Locale configurations | `map(object)` | See variables.tf | no |
| intents | Intent definitions | `map(object)` | `{}` | no |
| slots | Slot definitions | `map(object)` | `{}` | no |
| custom_slot_types | Custom slot type definitions | `map(object)` | `{}` | no |
| create_version | Create bot version | `bool` | `true` | no |
| bot_aliases | Alias configurations | `map(object)` | `{}` | no |
| create_role | Create IAM role | `bool` | `true` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bot_id | Bot ID |
| bot_arn | Bot ARN |
| bot_name | Bot name |
| intent_ids | Map of intent IDs |
| slot_ids | Map of slot IDs |
| bot_version | Bot version number |
| alias_ids | Map of alias IDs |
| alias_arns | Map of alias ARNs |
| role_arn | IAM role ARN |
| bot_endpoint | Integration endpoint information |
| summary | Deployment summary |

## Code Hooks

AWS Lex supports two types of Lambda code hooks:

### Dialog Code Hook
- **Purpose**: Invoked at each conversation turn during slot elicitation
- **Use Cases**: 
  - Validate slot values
  - Perform initialization logic
  - Dynamically modify prompts
  - Add business logic during conversation
- **Configuration**: Set `enable_dialog_code_hook = true` in intent configuration
- **Lambda Trigger**: Called before each slot is filled

### Fulfillment Code Hook
- **Purpose**: Invoked after all required slots are filled
- **Use Cases**:
  - Complete the intent's business logic
  - Return final response to user
  - Integrate with backend systems
- **Configuration**: Set `enable_fulfillment_code_hook = true` in intent configuration
- **Lambda Trigger**: Called once after slot collection

Both hooks can be enabled simultaneously for maximum flexibility.

## Built-in Slot Types

AWS Lex provides many built-in slot types you can use without creating custom types:

- `AMAZON.Number` - Numeric values
- `AMAZON.Date` - Calendar dates
- `AMAZON.Time` - Time values
- `AMAZON.Duration` - Time durations
- `AMAZON.PhoneNumber` - Phone numbers
- `AMAZON.EmailAddress` - Email addresses
- `AMAZON.AlphaNumeric` - Alphanumeric strings
- `AMAZON.FirstName` - First names
- `AMAZON.LastName` - Last names
- `AMAZON.City` - City names
- `AMAZON.Country` - Country names

[Full list of built-in slot types](https://docs.aws.amazon.com/lexv2/latest/dg/howitworks-builtins-slots.html)

## Lambda Integration

To integrate Lambda functions for fulfillment:

1. **Create Lambda function**
2. **Grant Lex permission to invoke Lambda**:
   ```hcl
   resource "aws_lambda_permission" "lex_invoke" {
     statement_id  = "AllowLexInvoke"
     action        = "lambda:InvokeFunction"
     function_name = aws_lambda_function.fulfillment.function_name
     principal     = "lexv2.amazonaws.com"
     source_arn    = module.lex_bot.bot_arn
   }
   ```
3. **Configure alias with Lambda ARN** in locale_settings

## Regional Deployment Considerations

### AWS Region Support
- **AWS Lex V2 Availability**: Verify Lex V2 is available in your target region
- **Default Configuration**: Examples configured for `eu-west-2` (London)
- **IAM Permissions**: Ensure IAM policies grant permissions for your deployment region
- **Voice Support**: Confirm Amazon Polly voices are available in target region
  - `en_GB` locale uses `Amy` (neural voice) - available in eu-west-2
  - Check [Polly voice availability](https://docs.aws.amazon.com/polly/latest/dg/voicelist.html) for other regions

### Locale-Specific Considerations

#### British English (en_GB)
- **Date Format**: Uses DD/MM/YYYY format (e.g., 25/12/2025)
- **AMAZON.Date Slot**: Returns dates in YYYY-MM-DD format regardless of locale
- **User Input**: Lex interprets "25/12" as 25th December in en_GB, 12th February in en_US
- **Recommendation**: Use explicit date validation in dialog hooks for ambiguous inputs

#### US English (en_US)
- **Date Format**: Uses MM/DD/YYYY format
- **Alternative Voices**: Joanna, Matthew, Kendra, Justin (neural)

### Cross-Region Deployment
When deploying to multiple regions:
- Use separate Terraform workspaces or state files per region
- Ensure Lambda functions for fulfillment are deployed in same region
- Configure regional CloudWatch Log Groups
- Adjust IAM policies to restrict or expand regional scope as needed

## Best Practices

### Intent Design
- Provide 5-10 diverse sample utterances per intent
- Use slot placeholders in utterances: `{SlotName}`
- Enable confirmation for critical actions (bookings, purchases)
- Set appropriate slot priorities for guided conversations

### Slot Configuration
- Mark critical slots as required
- Provide clear prompts for slot elicitation
- Use built-in slot types when available
- Add default values for optional slots
- **Date Slots**: Consider locale-specific date formats (DD/MM/YYYY for en_GB, MM/DD/YYYY for en_US)
- **Validation**: Use dialog hooks to validate date inputs and handle ambiguous formats

### Version Management
- Always create versions for production deployments
- Use aliases to route traffic to specific versions
- Test in staging alias before promoting to production
- Document version changes

### Logging and Monitoring
- Enable CloudWatch logs for debugging
- Use S3 audio logs for voice interactions
- Enable sentiment analysis for user insights
- Set appropriate log retention periods

## Terraform Commands and State Management

### Backend Configuration for S3 State

Configure S3 backend in your root module:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "lex-bot/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Targeted Terraform Operations

#### Update Bot Configuration Only

```bash
terraform apply -target=module.lex_bot.aws_lexv2models_bot.this
terraform apply -target=module.lex_bot.aws_lexv2models_bot_locale.this
```

#### Update Intents Only

```bash
# All intents
terraform apply -target=module.lex_bot.aws_lexv2models_intent.this

# Specific intent
terraform apply -target='module.lex_bot.aws_lexv2models_intent.this["BookRoom"]'
```

#### Update Slots Only

```bash
# All slots
terraform apply -target=module.lex_bot.aws_lexv2models_slot.this

# Custom slot types
terraform apply -target=module.lex_bot.aws_lexv2models_slot_type.this
```

#### Update Versions and Aliases Only

```bash
# Create new version
terraform apply -target=module.lex_bot.aws_lexv2models_bot_version.this

# Update aliases
terraform apply -target=module.lex_bot.aws_lexv2models_bot_alias.this
```

#### Update IAM Role Only

```bash
terraform apply -target=module.lex_bot.aws_iam_role.lex_bot
terraform apply -target=module.lex_bot.aws_iam_role_policy.lex_bot_basic
```

### State Verification

```bash
# List all resources
terraform state list

# Show bot details
terraform state show 'module.lex_bot.aws_lexv2models_bot.this'

# Show specific intent
terraform state show 'module.lex_bot.aws_lexv2models_intent.this["Greeting"]'

# Check S3 state
aws s3 ls s3://my-terraform-state-bucket/lex-bot/terraform.tfstate
```

## Module-Level vs Component-Level Operations

### Component Mapping

| Component | File | Resource Type | Target Flag Example |
|-----------|------|---------------|---------------------|
| **Bot** | main.tf | `aws_lexv2models_bot` | `-target=module.lex_bot.aws_lexv2models_bot.this` |
| **Bot Locale** | main.tf | `aws_lexv2models_bot_locale` | `-target=module.lex_bot.aws_lexv2models_bot_locale.this` |
| **Intents** | intents.tf | `aws_lexv2models_intent` | `-target=module.lex_bot.aws_lexv2models_intent.this` |
| **Slots** | slots.tf | `aws_lexv2models_slot` | `-target=module.lex_bot.aws_lexv2models_slot.this` |
| **Slot Types** | slots.tf | `aws_lexv2models_slot_type` | `-target=module.lex_bot.aws_lexv2models_slot_type.this` |
| **Bot Version** | versions_and_aliases.tf | `aws_lexv2models_bot_version` | `-target=module.lex_bot.aws_lexv2models_bot_version.this` |
| **Bot Alias** | versions_and_aliases.tf | `aws_lexv2models_bot_alias` | `-target=module.lex_bot.aws_lexv2models_bot_alias.this` |
| **IAM Role** | iam.tf | `aws_iam_role` | `-target=module.lex_bot.aws_iam_role.lex_bot` |

### Example: Add New Intent Without Affecting Others

```bash
# 1. Add intent to terraform.tfvars
cat >> terraform.tfvars <<'EOF'
intents = {
  # ... existing intents ...
  "CancelBooking" = {
    locale_id = "en_GB"
    sample_utterances = ["cancel my booking", "I want to cancel"]
    closing_message = "Your booking has been cancelled."
  }
}
EOF

# 2. Plan intent changes
terraform plan -target=module.lex_bot.aws_lexv2models_intent.this

# 3. Apply only intent changes
terraform apply -target=module.lex_bot.aws_lexv2models_intent.this

# 4. Verify
terraform state list | grep intent
```

## Examples

See the `examples/` directory for complete working examples:
- [`basic-bot/`](examples/basic-bot/) - Simple customer service bot with three intents
- [`booking-bot-simple/`](examples/booking-bot-simple/) - Hotel booking with custom slots and Lambda fulfillment (matches README example)
- [`lambda-integration/`](examples/lambda-integration/) - Advanced bot with both dialog and fulfillment hooks
  - Dialog hook for real-time slot validation
  - Fulfillment hook for booking processing
  - Complete Python Lambda function examples

## References

- [AWS Lex V2 Documentation](https://docs.aws.amazon.com/lexv2/latest/dg/)
- [Terraform AWS Provider - Lex V2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lexv2models_bot)
- [Lex Lambda Integration](https://docs.aws.amazon.com/lexv2/latest/dg/lambda.html)
