#!/bin/bash
# Script to build Lambda function package

set -e

echo "Building Lambda function..."

# Create function package
echo "Creating function zip file..."
cd function
zip -r function.zip app.py api.py -q
cd ..

echo "Function package created: function/function.zip"
echo "Function size: $(du -h function/function.zip | cut -f1)"
