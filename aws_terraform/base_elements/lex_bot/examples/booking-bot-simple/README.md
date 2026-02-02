# Simple Booking Bot Example

This example demonstrates a hotel booking bot with custom slot types and Lambda fulfillment integration, matching the code shown in the main README.

## Features

- ✅ Custom slot type for room types (single, double, suite)
- ✅ Three slots: RoomType, CheckInDate, Nights
- ✅ Dialog code hook enabled for validation
- ✅ Fulfillment code hook with Lambda function
- ✅ Confirmation prompt before booking
- ✅ Success and failure response messages
- ✅ CloudWatch logging
- ✅ Sentiment analysis

## Architecture

```
User → Lex Bot → Dialog Hook (validation)
              ↓
            Confirmation
              ↓
        Lambda Fulfillment → Booking Confirmation
```

## Quick Start

### Deploy

```bash
cd aws_terraform/base_elements/lex_bot/examples/booking-bot-simple
terraform init
terraform plan
terraform apply
```

### Test

```bash
# Get test command
terraform output -raw test_command | bash

# Or test manually
aws lexv2-runtime recognize-text \
  --bot-id <bot-id> \
  --bot-alias-id <alias-id> \
  --locale-id en_GB \
  --session-id test-001 \
  --text "I want to book a double room" \
  --region eu-west-2
```

## Lambda Function

The [`lambda/booking_fulfillment.py`](lambda/booking_fulfillment.py) function:
- Processes bookings after confirmation
- Generates unique booking confirmation numbers
- Calculates pricing based on room type and nights
- Formats dates for en_GB locale (DD/MM/YYYY)
- Returns booking confirmation with details

### Pricing
- Single room: £89.99/night
- Double room: £129.99/night
- Suite: £249.99/night

## Conversation Flow

```
User: I want to book a room
Bot:  What type of room would you like - single, double, or suite?

User: double
Bot:  When would you like to check in?

User: 15th March
Bot:  How many nights will you be staying?

User: 3
Bot:  Would you like to book a double room for 3 nights starting 15/03/2026?

User: yes
Bot:  Excellent! Your double room has been successfully booked.
      📅 Check-in: 15/03/2026
      🌙 Duration: 3 nights
      💰 Total: £389.97
      🎫 Confirmation Number: ABC12345
      
      A confirmation email will be sent shortly. We look forward to welcoming you!
```

## Custom Slot Type

The `RoomType` custom slot type includes:
- **single**: synonyms ["single room", "one bed", "solo"]
- **double**: synonyms ["double room", "two beds", "twin"]
- **suite**: synonyms ["luxury suite", "executive suite", "presidential"]

Resolution strategy: `TopResolution` (Lex selects the best matching value)

## Monitoring

### View Lambda Logs
```bash
aws logs tail /aws/lambda/HotelBookingBot-fulfillment --follow --region eu-west-2
```

### View Lex Bot Logs
```bash
aws logs tail /aws/lex/HotelBookingBot --follow --region eu-west-2
```

## Customization

### Add More Room Types
Edit `main.tf` and add values to the `RoomType` custom slot type:
```hcl
values = [
  {
    value    = "deluxe"
    synonyms = ["deluxe room", "premium room"]
  }
]
```

Update pricing in `lambda/booking_fulfillment.py`:
```python
room_prices = {
    'single': 89.99,
    'double': 129.99,
    'suite': 249.99,
    'deluxe': 179.99  # Add new room type
}
```

### Change Date Format
To use US date format (MM/DD/YYYY), modify `lambda/booking_fulfillment.py`:
```python
def format_date_for_display(iso_date):
    date_obj = datetime.strptime(iso_date, '%Y-%m-%d')
    return date_obj.strftime('%m/%d/%Y')  # US format
```

### Add Backend Integration
Replace the simulated booking in `booking_fulfillment.py` with real API calls:
```python
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Bookings')

table.put_item(Item=booking_data)
```

## Outputs

- `bot_id` - Bot ID for API calls
- `bot_arn` - Bot ARN for permissions
- `production_alias_id` - Alias ID for production testing
- `lambda_function_arn` - Lambda function ARN
- `test_command` - Ready-to-use test command
- `cloudwatch_log_group` - Log group name

## Clean Up

```bash
terraform destroy
```

## Related Examples

- [`basic-bot/`](../basic-bot/) - Simple bot without Lambda
- [`lambda-integration/`](../lambda-integration/) - Advanced example with dialog and fulfillment hooks

## References

- [AWS Lex V2 Custom Slot Types](https://docs.aws.amazon.com/lexv2/latest/dg/custom-slot-types.html)
- [Lex Lambda Integration](https://docs.aws.amazon.com/lexv2/latest/dg/lambda.html)
- [AMAZON.Date Slot Type](https://docs.aws.amazon.com/lexv2/latest/dg/built-in-slot-date.html)
