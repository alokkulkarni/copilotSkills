# Basic Customer Service Bot Example

Simple example demonstrating a customer service Lex bot with three intents.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Testing

Use AWS CLI to test:

```bash
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <alias-id> \
  --locale-id en_GB \
  --session-id test-123 \
  --text "Hello" \
  --region eu-west-2
```

## Features

- Three intents: Greeting, Help, Goodbye
- CloudWatch logging enabled
- Sentiment analysis enabled
- Production alias configured
