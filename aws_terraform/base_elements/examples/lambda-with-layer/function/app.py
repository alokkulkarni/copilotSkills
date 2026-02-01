"""
Lambda function that uses dependencies from Lambda layer.
This example demonstrates using the requests library from the layer.
"""

import json
import os
import logging
from datetime import datetime

# These imports come from the Lambda layer
try:
    import requests
    import boto3
    from dateutil import parser
    import pytz
except ImportError as e:
    print(f"Import error: {e}")
    print("Make sure the Lambda layer is attached with required dependencies")

# Configure logging
logger = logging.getLogger()
log_level = os.environ.get('LOG_LEVEL', 'INFO')
logger.setLevel(getattr(logging, log_level))


def handler(event, context):
    """
    Lambda function handler.
    
    Args:
        event: Event data passed to the function
        context: Lambda context object
        
    Returns:
        dict: Response object with statusCode and body
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    layer_version = os.environ.get('LAYER_VERSION', 'unknown')
    
    try:
        action = event.get('action', 'process')
        data = event.get('data', {})
        
        if action == 'process':
            result = process_data(data)
        elif action == 'fetch':
            url = event.get('url', 'https://httpbin.org/json')
            result = fetch_data(url)
        else:
            result = {'message': f'Unknown action: {action}'}
        
        # Add metadata
        result['metadata'] = {
            'timestamp': datetime.now(pytz.UTC).isoformat(),
            'environment': environment,
            'layer_version': layer_version,
            'function_name': context.function_name,
            'request_id': context.request_id
        }
        
        response = {
            'statusCode': 200,
            'body': json.dumps(result, indent=2)
        }
        
        logger.info("Request processed successfully")
        return response
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Internal server error'
            })
        }


def process_data(data):
    """Process data using layer dependencies."""
    logger.info(f"Processing data: {data}")
    
    # Example: Use boto3 from layer to list S3 buckets
    try:
        s3 = boto3.client('s3')
        buckets = s3.list_buckets()
        bucket_count = len(buckets.get('Buckets', []))
    except Exception as e:
        logger.warning(f"Could not list S3 buckets: {e}")
        bucket_count = 0
    
    return {
        'message': 'Data processed successfully',
        'data': data,
        's3_buckets_accessible': bucket_count,
        'layer_libraries': ['requests', 'boto3', 'python-dateutil', 'pytz']
    }


def fetch_data(url):
    """Fetch data from URL using requests library from layer."""
    logger.info(f"Fetching data from: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        return {
            'message': 'Data fetched successfully',
            'url': url,
            'status_code': response.status_code,
            'data': response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text[:100]
        }
    except requests.RequestException as e:
        logger.error(f"Request failed: {e}")
        raise


if __name__ == "__main__":
    # For local testing
    test_event = {
        'action': 'process',
        'data': {'key': 'value'}
    }
    
    class MockContext:
        function_name = 'test-function'
        request_id = 'test-request-id'
    
    result = handler(test_event, MockContext())
    print(json.dumps(result, indent=2))
