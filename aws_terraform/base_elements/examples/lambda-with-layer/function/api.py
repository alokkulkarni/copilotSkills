"""
API Lambda function with Function URL support.
Handles HTTP requests through Lambda Function URL.
"""

import json
import os
import logging
from datetime import datetime

try:
    import requests
    import pytz
except ImportError as e:
    print(f"Import error: {e}")

logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))


def handler(event, context):
    """
    Handle HTTP requests from Lambda Function URL.
    
    Args:
        event: Function URL event with HTTP request details
        context: Lambda context object
        
    Returns:
        dict: HTTP response with statusCode, headers, and body
    """
    logger.info(f"Received HTTP request: {event.get('requestContext', {}).get('http', {})}")
    
    try:
        # Parse HTTP request
        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
        path = event.get('rawPath', '/')
        query_params = event.get('queryStringParameters', {})
        headers = event.get('headers', {})
        body = event.get('body', '')
        
        # Route request
        if path == '/' and http_method == 'GET':
            response_body = handle_root(query_params)
        elif path == '/health' and http_method == 'GET':
            response_body = handle_health()
        elif path == '/api/data' and http_method == 'POST':
            request_data = json.loads(body) if body else {}
            response_body = handle_post_data(request_data)
        else:
            response_body = {
                'error': 'Not found',
                'path': path,
                'method': http_method
            }
            status_code = 404
            return create_response(status_code, response_body)
        
        return create_response(200, response_body)
        
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        return create_response(400, {'error': 'Invalid JSON in request body'})
        
    except Exception as e:
        logger.error(f"Error handling request: {e}", exc_info=True)
        return create_response(500, {'error': 'Internal server error', 'message': str(e)})


def handle_root(query_params):
    """Handle root path request."""
    return {
        'message': 'Welcome to Lambda Function URL API',
        'timestamp': datetime.now(pytz.UTC).isoformat(),
        'environment': os.environ.get('ENVIRONMENT', 'unknown'),
        'query_params': query_params,
        'endpoints': {
            'GET /': 'This message',
            'GET /health': 'Health check',
            'POST /api/data': 'Process data'
        }
    }


def handle_health():
    """Handle health check request."""
    return {
        'status': 'healthy',
        'timestamp': datetime.now(pytz.UTC).isoformat(),
        'checks': {
            'requests_library': check_library_import('requests'),
            'boto3_library': check_library_import('boto3'),
            'pytz_library': check_library_import('pytz')
        }
    }


def handle_post_data(data):
    """Handle POST data request."""
    logger.info(f"Processing POST data: {data}")
    
    return {
        'message': 'Data received and processed',
        'timestamp': datetime.now(pytz.UTC).isoformat(),
        'received_data': data,
        'processed': True
    }


def check_library_import(library_name):
    """Check if a library can be imported."""
    try:
        __import__(library_name)
        return 'available'
    except ImportError:
        return 'not available'


def create_response(status_code, body):
    """Create HTTP response object."""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps(body, indent=2)
    }


if __name__ == "__main__":
    # For local testing
    test_event = {
        'requestContext': {
            'http': {
                'method': 'GET',
                'path': '/'
            }
        },
        'rawPath': '/',
        'queryStringParameters': {'test': 'true'}
    }
    
    class MockContext:
        function_name = 'test-api-function'
        request_id = 'test-request-id'
    
    result = handler(test_event, MockContext())
    print(json.dumps(result, indent=2))
