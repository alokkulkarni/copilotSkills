"""
Dialog Hook Lambda Function for AWS Lex V2
Purpose: Validates slot values during conversation and provides dynamic responses
Invoked: At each conversation turn before slot is filled
"""

import json
import logging
from datetime import datetime, timedelta

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Main handler for Lex dialog hook
    
    Event structure:
    - sessionState: contains intent, slots, and session attributes
    - invocationSource: DialogCodeHook or FulfillmentCodeHook
    - bot: bot information
    - inputTranscript: user's input text
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    intent_name = event['sessionState']['intent']['name']
    invocation_source = event['invocationSource']
    
    # Route to appropriate intent handler
    if intent_name == 'BookRoom':
        return handle_book_room_dialog(event)
    elif intent_name == 'CancelBooking':
        return handle_cancel_booking_dialog(event)
    elif intent_name == 'CheckAvailability':
        return handle_check_availability_dialog(event)
    else:
        # Default response
        return delegate(event)


def handle_book_room_dialog(event):
    """Validate booking slots during conversation"""
    slots = event['sessionState']['intent']['slots']
    
    # Validate RoomType
    if slots.get('RoomType') and slots['RoomType'].get('value'):
        room_type = slots['RoomType']['value']['interpretedValue']
        if room_type.lower() not in ['single', 'double', 'suite']:
            return elicit_slot(
                event,
                'RoomType',
                "I'm sorry, we only have single, double, or suite rooms. Which would you prefer?"
            )
    
    # Validate CheckInDate
    if slots.get('CheckInDate') and slots['CheckInDate'].get('value'):
        check_in_date_str = slots['CheckInDate']['value']['interpretedValue']
        try:
            check_in_date = datetime.strptime(check_in_date_str, '%Y-%m-%d')
            today = datetime.now()
            
            # Check if date is in the past
            if check_in_date.date() < today.date():
                return elicit_slot(
                    event,
                    'CheckInDate',
                    "The check-in date cannot be in the past. Please provide a future date."
                )
            
            # Check if date is too far in the future (e.g., more than 365 days)
            max_future_date = today + timedelta(days=365)
            if check_in_date > max_future_date:
                return elicit_slot(
                    event,
                    'CheckInDate',
                    "We can only accept bookings up to one year in advance. Please choose an earlier date."
                )
                
        except ValueError:
            return elicit_slot(
                event,
                'CheckInDate',
                "I couldn't understand that date. Please provide the check-in date in DD/MM/YYYY format."
            )
    
    # Validate Nights
    if slots.get('Nights') and slots['Nights'].get('value'):
        try:
            nights = int(slots['Nights']['value']['interpretedValue'])
            if nights < 1:
                return elicit_slot(
                    event,
                    'Nights',
                    "You must book at least one night. How many nights would you like to stay?"
                )
            if nights > 30:
                return elicit_slot(
                    event,
                    'Nights',
                    "We can only accept bookings up to 30 nights. For longer stays, please contact our reservations team."
                )
        except ValueError:
            return elicit_slot(
                event,
                'Nights',
                "Please provide a valid number of nights."
            )
    
    # Check room availability (simulated)
    if all(slots.get(slot) and slots[slot].get('value') for slot in ['RoomType', 'CheckInDate', 'Nights']):
        room_type = slots['RoomType']['value']['interpretedValue']
        availability = check_room_availability(room_type)
        
        if not availability:
            return elicit_slot(
                event,
                'RoomType',
                f"I'm sorry, we don't have any {room_type} rooms available for those dates. Would you like to try a different room type?"
            )
    
    # All validations passed, delegate back to Lex
    return delegate(event)


def handle_cancel_booking_dialog(event):
    """Validate booking number for cancellation"""
    slots = event['sessionState']['intent']['slots']
    
    if slots.get('BookingNumber') and slots['BookingNumber'].get('value'):
        booking_number = slots['BookingNumber']['value']['interpretedValue']
        
        # Validate booking number format (alphanumeric, 6-8 characters)
        if not booking_number.isalnum() or len(booking_number) < 6 or len(booking_number) > 8:
            return elicit_slot(
                event,
                'BookingNumber',
                "That doesn't look like a valid booking number. Booking numbers are 6-8 alphanumeric characters. Please try again."
            )
        
        # Check if booking exists (simulated)
        if not verify_booking_exists(booking_number):
            return elicit_slot(
                event,
                'BookingNumber',
                f"I couldn't find a booking with number {booking_number}. Please verify and try again."
            )
    
    return delegate(event)


def handle_check_availability_dialog(event):
    """Provide dynamic availability information"""
    slots = event['sessionState']['intent']['slots']
    
    # If room type is specified, check its availability
    if slots.get('RoomType') and slots['RoomType'].get('value'):
        room_type = slots['RoomType']['value']['interpretedValue']
        available_count = get_available_rooms(room_type)
        
        message = f"We currently have {available_count} {room_type} rooms available."
        
        return close(
            event,
            'Fulfilled',
            message
        )
    
    # General availability
    return close(
        event,
        'Fulfilled',
        "We have rooms available across all our room types. Would you like to book one?"
    )


# ========================================
# Helper Functions - Simulated Backend
# ========================================

def check_room_availability(room_type):
    """Simulate checking room availability"""
    # In real implementation, this would query a database or booking system
    import random
    return random.choice([True, True, True, False])  # 75% availability


def verify_booking_exists(booking_number):
    """Simulate verifying booking exists"""
    # In real implementation, this would query a database
    # For demo, accept any booking number starting with 'A' or 'B'
    return booking_number[0].upper() in ['A', 'B']


def get_available_rooms(room_type):
    """Simulate getting available room count"""
    import random
    return random.randint(1, 10)


# ========================================
# Lex Response Helper Functions
# ========================================

def delegate(event):
    """Delegate back to Lex to continue the conversation"""
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'Delegate'
            },
            'intent': event['sessionState']['intent']
        }
    }


def elicit_slot(event, slot_to_elicit, message):
    """Ask Lex to elicit a specific slot with a custom message"""
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'ElicitSlot',
                'slotToElicit': slot_to_elicit
            },
            'intent': event['sessionState']['intent']
        },
        'messages': [
            {
                'contentType': 'PlainText',
                'content': message
            }
        ]
    }


def close(event, fulfillment_state, message):
    """Close the dialog with a final message"""
    intent = event['sessionState']['intent']
    intent['state'] = fulfillment_state
    
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
