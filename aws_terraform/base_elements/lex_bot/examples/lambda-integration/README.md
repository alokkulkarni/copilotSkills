# Lambda Integration Example - Hotel Booking Bot

Complete example demonstrating AWS Lex bot with Lambda integration for both dialog and fulfillment hooks.

## Overview

This example shows how to:
- ✅ Create Lambda functions for dialog hook (validation) and fulfillment hook (business logic)
- ✅ Enable both hooks on Lex intents
- ✅ Grant proper IAM permissions for Lex to invoke Lambda
- ✅ Handle slot validation in real-time
- ✅ Process bookings and cancellations with Lambda
- ✅ Return dynamic responses based on business logic

## Architecture

```
User → Lex Bot → Dialog Hook Lambda (validation)
                ↓
              Lex Bot → Fulfillment Hook Lambda (business logic)
                ↓
              Response to User
```

## Features

### Dialog Hook (`dialog_hook.py`)
- **Purpose**: Validate slot values during conversation
- **Invoked**: At each conversation turn before slot is filled
- **Capabilities**:
  - Validate room type (single, double, suite)
  - Validate check-in date (not in past, within 365 days)
  - Validate number of nights (1-30)
  - Check room availability dynamically
  - Validate booking number format
  - Provide context-aware error messages

### Fulfillment Hook (`fulfillment_hook.py`)
- **Purpose**: Execute business logic after all slots collected
- **Invoked**: After all required slots filled and confirmed
- **Capabilities**:
  - Generate booking confirmation numbers
  - Calculate pricing based on room type and duration
  - Process booking creation
  - Handle booking cancellations
  - Format dates for display (DD/MM/YYYY for en_GB)
  - Store session attributes for follow-up

### Intents

#### 1. BookRoom
- **Dialog Hook**: ✅ Enabled (validation)
- **Fulfillment Hook**: ✅ Enabled (booking creation)
- **Slots**: RoomType, CheckInDate, Nights
- **Confirmation**: Required
- **Features**:
  - Real-time slot validation
  - Availability checking
  - Price calculation
  - Confirmation number generation

#### 2. CancelBooking
- **Dialog Hook**: ✅ Enabled (booking verification)
- **Fulfillment Hook**: ✅ Enabled (cancellation processing)
- **Slots**: BookingNumber
- **Features**:
  - Booking number validation
  - Cancellation processing
  - Refund calculation

#### 3. CheckAvailability
- **Dialog Hook**: ✅ Enabled (dynamic availability response)
- **Fulfillment Hook**: ❌ Not required
- **Features**:
  - Real-time availability check
  - Room count information

## Deployment

### Prerequisites
- AWS CLI configured
- Terraform >= 1.5.0
- Python 3.11 (for local Lambda testing)

### Steps

1. **Initialize Terraform**
   ```bash
   cd aws_terraform/base_elements/lex_bot/examples/lambda-integration
   terraform init
   ```

2. **Review the Plan**
   ```bash
   terraform plan
   ```

3. **Deploy**
   ```bash
   terraform apply
   ```

4. **Note the Outputs**
   ```bash
   terraform output
   ```

## Testing

### Test Room Booking
```bash
# Get the test command from Terraform outputs
terraform output -raw test_booking_command | bash

# Or use manually:
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <production-alias-id> \
  --locale-id en_GB \
  --session-id test-123 \
  --text "I want to book a double room" \
  --region eu-west-2
```

### Test Cancellation
```bash
# Get the test command from Terraform outputs
terraform output -raw test_cancellation_command | bash

# Or manually:
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <production-alias-id> \
  --locale-id en_GB \
  --session-id test-456 \
  --text "Cancel booking ABC12345" \
  --region eu-west-2
```

### Interactive Testing
For full conversation testing:
```bash
# Start a booking conversation
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <production-alias-id> \
  --locale-id en_GB \
  --session-id session-001 \
  --text "Book a room" \
  --region eu-west-2

# Lex will ask for room type
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <production-alias-id> \
  --locale-id en_GB \
  --session-id session-001 \
  --text "suite" \
  --region eu-west-2

# Continue with check-in date, nights, and confirmation
```

## Monitoring

### Lambda Logs
```bash
# Dialog Hook logs
aws logs tail /aws/lambda/HotelBookingBot-dialog-hook --follow --region eu-west-2

# Fulfillment Hook logs
aws logs tail /aws/lambda/HotelBookingBot-fulfillment-hook --follow --region eu-west-2
```

### Lex Bot Logs
```bash
aws logs tail /aws/lex/HotelBookingBot --follow --region eu-west-2
```

### CloudWatch Insights Query
```sql
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

## Customization

### Modify Dialog Hook Logic
Edit [`lambda/dialog_hook.py`](lambda/dialog_hook.py) to:
- Add new slot validations
- Integrate with external APIs for availability
- Add custom business rules
- Change validation thresholds

### Modify Fulfillment Hook Logic
Edit [`lambda/fulfillment_hook.py`](lambda/fulfillment_hook.py) to:
- Integrate with real booking system
- Add payment processing
- Send confirmation emails
- Update pricing logic
- Add loyalty program integration

### Add New Intents
Update [`main.tf`](main.tf):
1. Add intent configuration to `intents` map
2. Enable dialog and/or fulfillment hooks
3. Add required slots
4. Update Lambda functions to handle new intent

## IAM Permissions

### Lambda Execution Role
The Lambda functions have:
- ✅ CloudWatch Logs write access (AWSLambdaBasicExecutionRole)
- ⚠️ Add additional permissions for:
  - DynamoDB (if storing bookings)
  - SES (if sending emails)
  - SNS (if sending notifications)

### Lex Invocation Permissions
Lex has permission to invoke both Lambda functions via `aws_lambda_permission` resources.

## Cost Considerations

### Lambda
- **Free Tier**: 1M requests/month, 400,000 GB-seconds compute
- **Estimated**: ~$0.20/1000 requests after free tier

### Lex
- **Free Tier**: 10,000 text requests/month (12 months)
- **Estimated**: $0.00075/text request after free tier

### CloudWatch Logs
- **Free Tier**: 5GB ingestion/month
- **Estimated**: ~$0.50/GB after free tier

## Security Best Practices

1. **Secrets Management**: Use AWS Secrets Manager for API keys
2. **Encryption**: Enable encryption at rest for logs
3. **VPC**: Deploy Lambda in VPC for database access
4. **IAM**: Follow least privilege principle
5. **Input Validation**: Always validate and sanitize user input

## Troubleshooting

### Dialog Hook Not Triggering
- Verify `enable_dialog_code_hook = true` in intent
- Check Lambda permissions allow Lex invocation
- Review CloudWatch Logs for errors

### Fulfillment Hook Failures
- Verify Lambda function timeout is sufficient (30s recommended)
- Check slot values are properly populated
- Review Lambda execution role permissions
- Check CloudWatch Logs for exceptions

### Invalid Date Format
- Ensure dates are in YYYY-MM-DD format in Lambda
- Use DD/MM/YYYY format in messages for en_GB locale
- Handle timezone differences appropriately

## Production Checklist

- [ ] Replace simulated backend with real database
- [ ] Add error handling and retry logic
- [ ] Implement proper logging and monitoring
- [ ] Set up CloudWatch alarms for Lambda errors
- [ ] Configure X-Ray tracing for debugging
- [ ] Add unit tests for Lambda functions
- [ ] Implement CI/CD pipeline
- [ ] Review and optimize Lambda memory/timeout
- [ ] Enable Lambda reserved concurrency if needed
- [ ] Set up automated backups for conversation logs

## References

- [AWS Lex V2 Lambda Integration](https://docs.aws.amazon.com/lexv2/latest/dg/lambda.html)
- [Lex V2 Dialog Code Hook](https://docs.aws.amazon.com/lexv2/latest/dg/using-lambda.html)
- [Lex V2 Fulfillment Code Hook](https://docs.aws.amazon.com/lexv2/latest/dg/lambda-fulfillment.html)
- [Lambda Python SDK](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
