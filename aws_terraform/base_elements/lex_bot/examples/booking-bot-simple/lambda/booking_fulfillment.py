"""
Simple Booking Fulfillment Lambda Function for AWS Lex V2
Purpose: Process hotel room bookings after all slots are collected
Invoked: After confirmation from the user
"""

import json
import logging
import uuid
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Main handler for Lex fulfillment
    
    Event structure:
    - sessionState: contains intent, slots, and session attributes
    - invocationSource: DialogCodeHook or FulfillmentCodeHook
    - bot: bot information
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    intent_name = event['sessionState']['intent']['name']
    
    if intent_name == 'BookRoom':
        return fulfill_booking(event)
    else:
        return close_failed(event, "I'm sorry, I couldn't process that request.")


def fulfill_booking(event):
    """Process the room booking"""
    try:
        slots = event['sessionState']['intent']['slots']
        
        # Extract slot values
        room_type = slots['RoomType']['value']['interpretedValue']
        check_in_date = slots['CheckInDate']['value']['interpretedValue']
        nights = int(slots['Nights']['value']['interpretedValue'])
        
        # Generate booking confirmation number
        booking_number = generate_booking_number()
        
        # Calculate pricing
        room_prices = {
            'single': 89.99,
            'double': 129.99,
            'suite': 249.99
        }
        
        price_per_night = room_prices.get(room_type.lower(), 99.99)
        total_price = price_per_night * nights
        
        # Log the booking (in production, this would save to database)
        booking_data = {
            'booking_number': booking_number,
            'room_type': room_type,
            'check_in_date': check_in_date,
            'nights': nights,
            'total_price': total_price,
            'timestamp': datetime.now().isoformat()
        }
        logger.info(f"Booking created: {json.dumps(booking_data)}")
        
        # Format check-in date for display (DD/MM/YYYY for en_GB)
        check_in_display = format_date_for_display(check_in_date)
        
        # Create success message with booking details
        message = (
            f"Excellent! Your {room_type} room has been successfully booked.\n\n"
            f"📅 Check-in: {check_in_display}\n"
            f"🌙 Duration: {nights} night{'s' if nights > 1 else ''}\n"
            f"💰 Total: £{total_price:.2f}\n"
            f"🎫 Confirmation Number: {booking_number}\n\n"
            f"A confirmation email will be sent shortly. We look forward to welcoming you!"
        )
        
        # Store booking number in session for potential follow-up
        session_attributes = {
            'lastBookingNumber': booking_number,
            'lastBookingTotal': str(total_price)
        }
        
        return close_fulfilled(event, message, session_attributes, booking_number)
        
    except KeyError as e:
        logger.error(f"Missing required slot: {e}")
        return close_failed(event, "I'm sorry, some booking information is missing. Please try again.")
    except Exception as e:
        logger.error(f"Error processing booking: {e}")
        return close_failed(
            event,
            "I'm sorry, an unexpected error occurred. Please try again or contact support."
        )


def generate_booking_number():
    """Generate a unique booking confirmation number"""
    # Format: ABC12345 (3 letters + 5 digits)
    letters = ''.join([chr(ord('A') + (uuid.uuid4().int % 26)) for _ in range(3)])
    numbers = str(uuid.uuid4().int)[:5]
    return f"{letters}{numbers}"


def format_date_for_display(iso_date):
    """Convert ISO date (YYYY-MM-DD) to display format (DD/MM/YYYY for en_GB)"""
    try:
        date_obj = datetime.strptime(iso_date, '%Y-%m-%d')
        return date_obj.strftime('%d/%m/%Y')
    except:
        return iso_date


def close_fulfilled(event, message, session_attributes=None, booking_number=None):
    """Return successful fulfillment response"""
    intent = event['sessionState']['intent']
    intent['state'] = 'Fulfilled'
    
    # Add booking number to slot if provided
    if booking_number and 'slots' in intent:
        if 'BookingNumber' not in intent['slots'] or intent['slots']['BookingNumber'] is None:
            intent['slots']['BookingNumber'] = {
                'shape': 'Scalar',
                'value': {
                    'originalValue': booking_number,
                    'interpretedValue': booking_number,
                    'resolvedValues': [booking_number]
                }
            }
    
    response = {
        'sessionState': {
            'dialogAction': {
                'type': 'Close'
            },
            'intent': intent
        },
        'messages': [
            {
                'contentType': 'PlainText',
                'content': message
            }
        ]
    }
    
    if session_attributes:
        response['sessionState']['sessionAttributes'] = session_attributes
    
    return response


def close_failed(event, message):
    """Return failed fulfillment response"""
    intent = event['sessionState']['intent']
    intent['state'] = 'Failed'
    
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'Close'
            },
            'intent': intent
        },
        'messages': [
            {
                'contentType': 'PlainText',
                'content': message
            }
        ]
    }
