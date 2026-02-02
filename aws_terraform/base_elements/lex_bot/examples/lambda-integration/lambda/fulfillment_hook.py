"""
Fulfillment Hook Lambda Function for AWS Lex V2
Purpose: Execute business logic after all slots are collected
Invoked: After all required slots are filled and confirmation is complete
"""

import json
import logging
import uuid
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Main handler for Lex fulfillment hook
    
    Event structure:
    - sessionState: contains intent, slots, and session attributes
    - invocationSource: FulfillmentCodeHook
    - bot: bot information
    - inputTranscript: user's input text
    """
    logger.info(f"Received fulfillment event: {json.dumps(event)}")
    
    intent_name = event['sessionState']['intent']['name']
    
    # Route to appropriate intent fulfillment
    if intent_name == 'BookRoom':
        return fulfill_book_room(event)
    elif intent_name == 'CancelBooking':
        return fulfill_cancel_booking(event)
    else:
        return close_failed(event, "I'm sorry, I couldn't process that request.")


def fulfill_book_room(event):
    """Process room booking and return confirmation"""
    try:
        slots = event['sessionState']['intent']['slots']
        
        # Extract slot values
        room_type = slots['RoomType']['value']['interpretedValue']
        check_in_date = slots['CheckInDate']['value']['interpretedValue']
        nights = int(slots['Nights']['value']['interpretedValue'])
        
        # Generate booking confirmation number
        booking_number = generate_booking_number()
        
        # Calculate total price (simulated)
        room_prices = {
            'single': 89.99,
            'double': 129.99,
            'suite': 249.99
        }
        
        price_per_night = room_prices.get(room_type.lower(), 99.99)
        total_price = price_per_night * nights
        
        # Simulate booking in database
        booking_result = create_booking({
            'booking_number': booking_number,
            'room_type': room_type,
            'check_in_date': check_in_date,
            'nights': nights,
            'total_price': total_price,
            'timestamp': datetime.now().isoformat()
        })
        
        if booking_result['success']:
            # Format check-in date for display (DD/MM/YYYY for en_GB)
            check_in_display = format_date_for_display(check_in_date)
            
            message = (
                f"Excellent! Your {room_type} room has been successfully booked.\n\n"
                f"📅 Check-in: {check_in_display}\n"
                f"🌙 Duration: {nights} night{'s' if nights > 1 else ''}\n"
                f"💰 Total: £{total_price:.2f}\n"
                f"🎫 Confirmation: {booking_number}\n\n"
                f"A confirmation email has been sent. We look forward to welcoming you!"
            )
            
            # Store booking number in session attributes for potential follow-up
            session_attributes = event.get('sessionAttributes', {})
            session_attributes['lastBookingNumber'] = booking_number
            session_attributes['lastBookingTotal'] = str(total_price)
            
            return close_fulfilled(event, message, session_attributes)
        else:
            return close_failed(
                event,
                "I'm sorry, there was an error processing your booking. Please try again or contact our support team."
            )
            
    except KeyError as e:
        logger.error(f"Missing required slot: {e}")
        return close_failed(event, "I'm sorry, some booking information is missing. Please try again.")
    except Exception as e:
        logger.error(f"Error fulfilling booking: {e}")
        return close_failed(
            event,
            "I'm sorry, an unexpected error occurred. Please try again or contact support."
        )


def fulfill_cancel_booking(event):
    """Process booking cancellation"""
    try:
        slots = event['sessionState']['intent']['slots']
        booking_number = slots['BookingNumber']['value']['interpretedValue']
        
        # Retrieve booking details (simulated)
        booking_details = get_booking_details(booking_number)
        
        if not booking_details:
            return close_failed(
                event,
                f"I couldn't find a booking with number {booking_number}. Please verify and try again."
            )
        
        # Process cancellation (simulated)
        cancellation_result = cancel_booking(booking_number)
        
        if cancellation_result['success']:
            refund_amount = booking_details.get('total_price', 0)
            
            message = (
                f"Your booking {booking_number} has been successfully cancelled.\n\n"
                f"💰 Refund: £{refund_amount:.2f}\n"
                f"⏱️ Processing time: 5-7 business days\n\n"
                f"You will receive a confirmation email shortly. "
                f"We hope to see you again in the future!"
            )
            
            return close_fulfilled(event, message)
        else:
            return close_failed(
                event,
                f"There was an error cancelling booking {booking_number}. Please contact our support team."
            )
            
    except KeyError as e:
        logger.error(f"Missing booking number: {e}")
        return close_failed(event, "I need a booking number to process the cancellation.")
    except Exception as e:
        logger.error(f"Error fulfilling cancellation: {e}")
        return close_failed(event, "An unexpected error occurred. Please contact support.")


# ========================================
# Simulated Backend Functions
# ========================================

def generate_booking_number():
    """Generate a unique booking confirmation number"""
    # Format: ABC12345 (3 letters + 5 digits)
    letters = ''.join([chr(ord('A') + (uuid.uuid4().int % 26)) for _ in range(3)])
    numbers = str(uuid.uuid4().int)[:5]
    return f"{letters}{numbers}"


def create_booking(booking_data):
    """Simulate creating booking in database"""
    # In real implementation, this would insert into a database
    logger.info(f"Creating booking: {json.dumps(booking_data)}")
    
    # Simulate 98% success rate
    import random
    success = random.random() < 0.98
    
    return {
        'success': success,
        'booking_data': booking_data if success else None
    }


def get_booking_details(booking_number):
    """Simulate retrieving booking from database"""
    # In real implementation, this would query a database
    # For demo, return mock data for bookings starting with 'A' or 'B'
    if booking_number[0].upper() in ['A', 'B']:
        return {
            'booking_number': booking_number,
            'room_type': 'double',
            'check_in_date': '2026-03-15',
            'nights': 3,
            'total_price': 389.97,
            'status': 'confirmed'
        }
    return None


def cancel_booking(booking_number):
    """Simulate cancelling booking in database"""
    # In real implementation, this would update the database
    logger.info(f"Cancelling booking: {booking_number}")
    
    return {
        'success': True,
        'booking_number': booking_number
    }


def format_date_for_display(iso_date):
    """Convert ISO date (YYYY-MM-DD) to display format (DD/MM/YYYY for en_GB)"""
    try:
        date_obj = datetime.strptime(iso_date, '%Y-%m-%d')
        return date_obj.strftime('%d/%m/%Y')
    except:
        return iso_date


# ========================================
# Lex Response Helper Functions
# ========================================

def close_fulfilled(event, message, session_attributes=None):
    """Return successful fulfillment response"""
    intent = event['sessionState']['intent']
    intent['state'] = 'Fulfilled'
    
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
