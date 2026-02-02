# Lex Bot Operations Guide

Step-by-step procedures for common operational tasks with the Lex Bot Terraform module.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- S3 backend configured for state
- DynamoDB table for state locking

## Common Operations

### Adding a New Intent

```bash
# 1. Add intent to terraform.tfvars
intents = {
  # ... existing intents ...
  "CheckStatus" = {
    locale_id = "en_GB"
    description = "Check order status"
    sample_utterances = [
      "check my order status",
      "where is my order",
      "track my order"
    ]
    closing_message = "I found your order details."
  }
}

# 2. Plan changes
terraform plan -target=module.lex_bot.aws_lexv2models_intent.this

# 3. Apply
terraform apply -target=module.lex_bot.aws_lexv2models_intent.this

# 4. Verify
terraform state list | grep intent
```

### Adding New Slots

```bash
# 1. Add slot to terraform.tfvars
slots = {
  # ... existing slots ...
  "OrderNumber" = {
    intent_name = "CheckStatus"
    locale_id   = "en_GB"
    description = "Customer order number"
    slot_type_id = "AMAZON.AlphaNumeric"
    is_required  = true
    prompt_message = "What is your order number?"
  }
}

# 2. Apply
terraform apply -target=module.lex_bot.aws_lexv2models_slot.this

# 3. Verify
terraform state show 'module.lex_bot.aws_lexv2models_slot.this["OrderNumber"]'
```

### Creating a New Bot Version

```bash
# 1. Enable version creation
create_version = true
version_description = "Production release v1.0"

# 2. Create version
terraform apply -target=module.lex_bot.aws_lexv2models_bot_version.this

# 3. Get version number
terraform output bot_version
```

### Adding Bot Alias

```bash
# 1. Add alias configuration
bot_aliases = {
  "Production" = {
    description = "Production environment"
    bot_version = "1"  # or null to use latest
    locale_settings = {
      "en_GB" = {
        enabled    = true
        lambda_arn = "arn:aws:lambda:eu-west-2:123456789012:function:my-fulfillment"
      }
    }
  }
}

# 2. Apply
terraform apply -target=module.lex_bot.aws_lexv2models_bot_alias.this

# 3. Get alias ID
terraform output -json bot_alias_ids | jq '.Production'
```

### Connecting Lambda Function

```bash
# 1. Add Lambda ARN to alias locale settings
locale_settings = {
  "en_GB" = {
    enabled    = true
    lambda_arn = "arn:aws:lambda:eu-west-2:123456789012:function:my-bot-function"
  }
}

# 2. Enable fulfillment hook in intent
intents = {
  "BookRoom" = {
    # ... other config ...
    enable_fulfillment_code_hook = true
  }
}

# 3. Apply changes
terraform apply -target=module.lex_bot.aws_lexv2models_bot_alias.this

# 4. Verify Lambda permission
aws lambda get-policy --function-name my-bot-function
```

### Enabling Conversation Logs

```bash
# 1. Create CloudWatch log group first
resource "aws_cloudwatch_log_group" "lex_conversations" {
  name              = "/aws/lex/my-bot"
  retention_in_days = 30
}

# 2. Add to alias configuration
bot_aliases = {
  "Production" = {
    # ... other config ...
    enable_conversation_logs = true
    text_log_group_arn = aws_cloudwatch_log_group.lex_conversations.arn
  }
}

# 3. Apply
terraform apply -target=module.lex_bot.aws_lexv2models_bot_alias.this
```

## State Management

### Check State

```bash
# List bot resources
terraform state list | grep lex

# Show bot details
terraform state show 'module.lex_bot.aws_lexv2models_bot.this'

# Show specific intent
terraform state show 'module.lex_bot.aws_lexv2models_intent.this["Greeting"]'

# Verify S3 state
aws s3 ls s3://my-terraform-state-bucket/lex-bot/
```

### Import Existing Bot

```bash
# Import bot
terraform import module.lex_bot.aws_lexv2models_bot.this <bot-id>

# Import locale
terraform import 'module.lex_bot.aws_lexv2models_bot_locale.this["en_GB"]' <bot-id>,DRAFT,en_GB

# Import intent
terraform import 'module.lex_bot.aws_lexv2models_intent.this["Greeting"]' <bot-id>,<intent-id>,DRAFT,en_GB
```

## Testing

### Test Bot in Console

```bash
# Get bot ID
terraform output bot_id

# Open in AWS Console
echo "https://eu-west-2.console.aws.amazon.com/lexv2/home?region=eu-west-2#bot/<bot-id>"
```

### Test with AWS CLI

```bash
# Start conversation
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <alias-id> \
  --locale-id en_GB \
  --session-id test-session-123 \
  --text "hello"
```

## Troubleshooting

### Intent Not Working

```bash
# Check intent configuration
terraform state show 'module.lex_bot.aws_lexv2models_intent.this["MyIntent"]'

# Check sample utterances
# Verify NLU confidence threshold
# Review CloudWatch logs
```

### Lambda Integration Issues

```bash
# Verify Lambda permission
aws lambda get-policy --function-name my-bot-function

# Add permission if missing
aws lambda add-permission \
  --function-name my-bot-function \
  --statement-id AllowLex \
  --action lambda:InvokeFunction \
  --principal lexv2.amazonaws.com \
  --source-arn <bot-arn>
```

### Slot Validation Failing

```bash
# Check slot configuration
terraform state show 'module.lex_bot.aws_lexv2models_slot.this["MySlot"]'

# Verify slot type
# Check prompt message
# Review dialog code hook logic
```

## Best Practices

1. **Start with 5-10 sample utterances** per intent
2. **Use built-in slot types** when available
3. **Enable confirmation** for critical actions
4. **Create versions** for production
5. **Use aliases** for traffic management
6. **Enable conversation logs** for debugging
7. **Test thoroughly** in draft before publishing
8. **Document intent flows** for team reference
9. **Monitor NLU confidence** scores
10. **Iterate based on user feedback**

---

For comprehensive state management, see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md).
