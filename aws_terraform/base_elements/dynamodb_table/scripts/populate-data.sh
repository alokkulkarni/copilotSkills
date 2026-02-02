#!/bin/bash
# ============================================
# DynamoDB Data Population Script
# ============================================
# Populate DynamoDB table with JSON data
# Usage: ./scripts/populate-data.sh [table-name] [data-file]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
TABLE_NAME="${1}"
DATA_FILE="${2}"
REGION="${AWS_REGION:-us-east-1}"
BATCH_SIZE=25  # DynamoDB batch-write-item limit

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}DynamoDB Data Population${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Validate inputs
if [ -z "$TABLE_NAME" ]; then
    print_error "Table name is required"
    echo "Usage: $0 <table-name> <data-file>"
    exit 1
fi

if [ -z "$DATA_FILE" ]; then
    print_error "Data file is required"
    echo "Usage: $0 <table-name> <data-file>"
    exit 1
fi

if [ ! -f "$DATA_FILE" ]; then
    print_error "Data file not found: $DATA_FILE"
    exit 1
fi

print_info "Table: $TABLE_NAME"
print_info "Data file: $DATA_FILE"
print_info "Region: $REGION"

# Verify table exists
print_info "Verifying table exists..."
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &> /dev/null; then
    print_error "Table not found: $TABLE_NAME"
    exit 1
fi
print_status "Table verified"

# Parse JSON data
print_info "Parsing data file..."
ITEM_COUNT=$(jq '. | length' "$DATA_FILE")
print_status "Found $ITEM_COUNT items to insert"

# Create temporary directory for batch files
TMP_DIR=$(mktemp -d)
print_info "Using temporary directory: $TMP_DIR"

# Split data into batches
print_info "Creating batch files (batch size: $BATCH_SIZE)..."
jq -c --arg table "$TABLE_NAME" --argjson size "$BATCH_SIZE" '
  [to_entries | .[] | {
    "PutRequest": {
      "Item": .value
    }
  }] | 
  [range(0; length; $size) as $i | .[$i:$i+$size]] |
  to_entries[] |
  {
    ($table): .value
  }
' "$DATA_FILE" | split -l 1 - "$TMP_DIR/batch_"

BATCH_COUNT=$(ls -1 "$TMP_DIR"/batch_* 2>/dev/null | wc -l)
print_status "Created $BATCH_COUNT batch files"

# Process batches
SUCCESS_COUNT=0
FAILURE_COUNT=0

print_info "Starting data insertion..."
for batch_file in "$TMP_DIR"/batch_*; do
    BATCH_NUM=$((SUCCESS_COUNT + FAILURE_COUNT + 1))
    print_info "Processing batch $BATCH_NUM of $BATCH_COUNT..."
    
    if aws dynamodb batch-write-item \
        --request-items "file://$batch_file" \
        --region "$REGION" \
        --output json > /dev/null 2>&1; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        print_status "Batch $BATCH_NUM completed"
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        print_error "Batch $BATCH_NUM failed"
    fi
done

# Cleanup
print_info "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Data Population Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "Table: ${GREEN}$TABLE_NAME${NC}"
echo -e "Total Items: ${GREEN}$ITEM_COUNT${NC}"
echo -e "Batches Processed: ${GREEN}$BATCH_COUNT${NC}"
echo -e "Successful Batches: ${GREEN}$SUCCESS_COUNT${NC}"
echo -e "Failed Batches: ${RED}$FAILURE_COUNT${NC}"
echo ""

if [ $FAILURE_COUNT -eq 0 ]; then
    print_status "All data inserted successfully!"
    exit 0
else
    print_error "Some batches failed. Please check logs and retry."
    exit 1
fi
