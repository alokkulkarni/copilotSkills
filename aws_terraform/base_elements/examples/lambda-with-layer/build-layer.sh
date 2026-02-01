#!/bin/bash
# Script to build Lambda layer package

set -e

echo "Building Lambda layer..."

# Create layer directory structure
mkdir -p layer/python/lib/python3.11/site-packages

# Install dependencies
echo "Installing Python dependencies..."
pip install -r layer/requirements.txt -t layer/python/lib/python3.11/site-packages/ --quiet

# Create zip file
echo "Creating layer zip file..."
cd layer
zip -r python-layer.zip python/ -q
cd ..

echo "Layer package created: layer/python-layer.zip"
echo "Layer size: $(du -h layer/python-layer.zip | cut -f1)"
