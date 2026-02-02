# Lex and Lambda Integration Example

This example demonstrates a complete Amazon Connect contact center with integrated Amazon Lex bot and AWS Lambda functions for intelligent call routing and customer service automation.

## Module Structure

This example uses the modular Connect instance module with special focus on AI integrations:

| Component | Module File | Purpose |
|-----------|-------------|----------|
| Instance | main.tf | Core Connect configuration |
| Integrations | integrations.tf | **Lambda & Lex bot associations** |
| Contact Flows | contact_flows.tf | AI-powered call routing |
| Queues | queues.tf | AI escalation queues |
| Users | users.tf | Agents handling escalations |

### AI Integration Management

The **integrations.tf** file manages:
- Lambda function associations with automatic invoke permissions
- Lex bot associations with regional configuration
- Both can be independently added/removed via variables

```hcl
# Add more Lambda functions
lambda_functions = {
  customer_lookup = { function_arn = "..." }
  payment_processing = { function_arn = "..." }
}

# Add more Lex bots
lex_bots = [
  { name = "CustomerServiceBot", lex_region = "eu-west-2" }
  { name = "BillingBot", lex_region = "eu-west-2" }
]
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│               Customer Calls Connect Instance               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │   Contact Flow       │
          │   (Greeting)         │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │   Amazon Lex Bot     │
          │   (Intent Detection) │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │   AWS Lambda         │
          │   (Business Logic)   │
          └──────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
  ┌─────────────┐         ┌─────────────┐
  │  Transfer   │         │  Self-      │
  │  to Agent   │         │  Service    │
  └─────────────┘         └─────────────┘
```

## Features

- **Amazon Lex Integration**: Natural language understanding for customer intents
- **AWS Lambda Integration**: Custom business logic and data lookups
- **Intelligent Routing**: Route calls based on Lex intent and Lambda response
- **Self-Service Options**: Handle common requests without agent intervention
- **Graceful Fallback**: Transfer to live agent when needed
- **Complete Module Integration**: Uses existing lambda_function and lex_bot modules

## Prerequisites

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- Existing Lex bot (or use the lex_bot module from this repository)
- Lambda function for business logic (or use the lambda_function module)

## Usage

### Step 1: Deploy Lex Bot

First, deploy a Lex bot using the existing module:

```bash
cd ../../../lex_bot/examples/booking-bot-simple
terraform init
terraform apply
```

### Step 2: Note Lex Bot Details

After deployment, note the bot name and alias for Connect integration.

### Step 3: Deploy Lambda Function

Deploy a Lambda function using the existing module:

```bash
cd ../../../lambda_function/examples/simple-function
terraform init
terraform apply
```

### Step 4: Deploy Connect Instance

Update `terraform.tfvars` with your Lex bot and Lambda details:

```hcl
instance_alias = "my-ai-contact-center"
lex_bot_name   = "YourLexBotName"
lambda_arn     = "arn:aws:lambda:eu-west-2:123456789012:function:YourFunction"
```

Deploy the Connect instance:

```bash
terraform init
terraform plan
terraform apply
```

## Integration Details

### Lex Bot Configuration

The example associates a Lex bot with Connect:

```hcl
lex_bots = [
  {
    name       = var.lex_bot_name
    lex_region = var.aws_region
  }
]
```

### Lambda Function Association

The Lambda function is associated for invocation from contact flows:

```hcl
lambda_functions = {
  customer_service = {
    function_arn = var.lambda_arn
  }
}
```

### Contact Flow Logic

The contact flow (`lex-bot-flow.json`):
1. **Greets** the customer
2. **Connects** customer with Lex bot for intent detection
3. **Invokes** Lambda function with Lex session attributes
4. **Routes** based on Lambda response:
   - Self-service completion → Thank and disconnect
   - Requires agent → Transfer to queue
5. **Handles errors** gracefully with agent fallback

## Lambda Function Requirements

Your Lambda function should:

### Input Format

```json
{
  "Details": {
    "ContactData": {
      "Attributes": {
        "CustomerInput": "customer's request",
        "Intent": "detected intent name"
      }
    }
  }
}
```

### Output Format

```json
{
  "requiresAgent": "true",
  "responseMessage": "I've found your account information...",
  "customerId": "12345"
}
```

### Example Lambda (Python)

```python
import json

def lambda_handler(event, context):
    # Extract customer input and intent
    attributes = event['Details']['ContactData']['Attributes']
    intent = attributes.get('Intent', 'Unknown')
    customer_input = attributes.get('CustomerInput', '')
    
    # Business logic based on intent
    if intent == 'CheckBalance':
        # Perform balance lookup
        return {
            'requiresAgent': 'false',
            'responseMessage': 'Your balance is $1,234.56',
            'balance': '1234.56'
        }
    elif intent == 'TransferFunds':
        # Complex transaction - requires agent
        return {
            'requiresAgent': 'true',
            'responseMessage': 'Let me connect you with an agent for this transaction'
        }
    else:
        # Unknown intent - transfer to agent
        return {
            'requiresAgent': 'true',
            'responseMessage': 'Let me find someone who can help you'
        }
```

## Lex Bot Requirements

Your Lex bot should:

### Intents

Define intents for common customer requests:
- `CheckBalance`: Check account balance
- `TransferFunds`: Transfer money between accounts
- `ReportIssue`: Report a problem
- `GeneralInquiry`: General questions

### Session Attributes

Pass relevant data to Lambda:
```json
{
  "customerInput": "user's full request",
  "accountNumber": "extracted account number",
  "requestType": "type of request"
}
```

### Fulfillment

Set fulfillment to return control to Connect contact flow.

## Testing

### Test the Integration

1. **Call the Connect instance** using a claimed phone number
2. **Speak naturally** when prompted by Lex bot
3. **Verify Lex** correctly identifies intent
4. **Check Lambda** processes request and returns appropriate response
5. **Confirm routing**:
   - Self-service: Call ends with confirmation
   - Agent needed: Transferred to queue

### Monitor Execution

- **CloudWatch Logs**: Review Connect contact flow logs
- **Lambda Logs**: Check Lambda execution logs
- **Lex Analytics**: Review bot conversation analytics
- **Connect Metrics**: Monitor queue and agent performance

## Outputs

The example provides:
- Connect instance details
- Lex bot association confirmation
- Lambda function association confirmation
- Queue and routing profile IDs
- User account information
- Console access URL

## Cost Considerations

- **Connect**: Per-user fee + usage charges
- **Lex**: Per text/voice request
- **Lambda**: Per invocation + duration
- **CloudWatch**: Log storage and analysis

Estimate: $X-Y per month for moderate usage

## Troubleshooting

### Lex Bot Not Responding

**Symptoms**: Contact flow doesn't connect to Lex
**Solutions**:
- Verify bot is in AVAILABLE state
- Check bot alias is correct
- Ensure bot region matches Connect region
- Review IAM permissions for Connect to invoke Lex

### Lambda Function Errors

**Symptoms**: Contact flow shows Lambda error
**Solutions**:
- Check Lambda permissions for Connect invocation
- Verify Lambda timeout is < 8 seconds
- Review Lambda CloudWatch logs
- Validate Lambda return format

### Call Disconnects Unexpectedly

**Symptoms**: Call drops during Lex or Lambda execution
**Solutions**:
- Check contact flow configuration
- Verify all error handlers are configured
- Review CloudWatch logs for flow execution
- Ensure Lambda completes within timeout

## Advanced Customization

### Add More Lex Bots

```hcl
lex_bots = [
  {
    name       = "GeneralSupportBot"
    lex_region = "eu-west-2"
  },
  {
    name       = "BillingBot"
    lex_region = "eu-west-2"
  }
]
```

### Add More Lambda Functions

```hcl
lambda_functions = {
  customer_lookup = {
    function_arn = module.customer_lookup_lambda.function_arn
  }
  payment_processing = {
    function_arn = module.payment_lambda.function_arn
  }
}
```

### Customize Contact Flow

Edit `contact-flows/lex-bot-flow.json` to:
- Add more intents
- Implement different routing logic
- Add data collection steps
- Include additional Lambda invocations

## Best Practices

1. **Lex Design**: Start with 3-5 core intents, expand gradually
2. **Lambda Performance**: Keep execution time < 3 seconds
3. **Error Handling**: Always provide agent fallback
4. **Testing**: Test all intent paths thoroughly
5. **Monitoring**: Set up CloudWatch alarms for failures
6. **Security**: Use IAM roles, never hardcode credentials
7. **Versioning**: Use Lex bot versions and aliases

## Resources

- [Amazon Connect + Lex Integration](https://docs.aws.amazon.com/connect/latest/adminguide/amazon-lex.html)
- [Connect Lambda Integration](https://docs.aws.amazon.com/connect/latest/adminguide/connect-lambda-functions.html)
- [Contact Flow Best Practices](https://docs.aws.amazon.com/connect/latest/adminguide/contact-flow-best-practices.html)
- [Lex V2 Documentation](https://docs.aws.amazon.com/lexv2/latest/dg/)

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-02
