#!/bin/bash
# ============================================
# DynamoDB Table Validation Script
# ============================================
# Validate table configuration and health
# Usage: ./scripts/validate-table.sh [table-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
TABLE_NAME="${1}"
REGION="${AWS_REGION:-us-east-1}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}DynamoDB Table Validation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Validate inputs
if [ -z "$TABLE_NAME" ]; then
    print_error "Table name is required"
    echo "Usage: $0 <table-name>"
    exit 1
fi

print_info "Validating table: $TABLE_NAME"
print_info "Region: $REGION"
echo ""

# Check if table exists
print_info "Checking table existence..."
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &> /dev/null; then
    print_status "Table exists"
else
    print_error "Table not found: $TABLE_NAME"
    exit 1
fi

# Get table details
TABLE_INFO=$(aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION")

# Check table status
print_info "Checking table status..."
STATUS=$(echo "$TABLE_INFO" | jq -r '.Table.TableStatus')
if [ "$STATUS" == "ACTIVE" ]; then
    print_status "Table is ACTIVE"
else
    print_warning "Table status: $STATUS"
fi

# Check billing mode
print_info "Checking billing mode..."
BILLING_MODE=$(echo "$TABLE_INFO" | jq -r '.Table.BillingModeSummary.BillingMode // "PROVISIONED"')
echo -e "  Billing Mode: ${GREEN}$BILLING_MODE${NC}"

if [ "$BILLING_MODE" == "PROVISIONED" ]; then
    READ_CAPACITY=$(echo "$TABLE_INFO" | jq -r '.Table.ProvisionedThroughput.ReadCapacityUnits')
    WRITE_CAPACITY=$(echo "$TABLE_INFO" | jq -r '.Table.ProvisionedThroughput.WriteCapacityUnits')
    echo -e "  Read Capacity: ${GREEN}$READ_CAPACITY${NC}"
    echo -e "  Write Capacity: ${GREEN}$WRITE_CAPACITY${NC}"
fi

# Check encryption
print_info "Checking encryption..."
ENCRYPTION=$(echo "$TABLE_INFO" | jq -r '.Table.SSEDescription.Status // "DISABLED"')
if [ "$ENCRYPTION" == "ENABLED" ]; then
    print_status "Encryption is enabled"
    KMS_KEY=$(echo "$TABLE_INFO" | jq -r '.Table.SSEDescription.KMSMasterKeyArn // "AWS Managed"')
    echo -e "  KMS Key: ${GREEN}$KMS_KEY${NC}"
else
    print_warning "Encryption is disabled"
fi

# Check point-in-time recovery
print_info "Checking point-in-time recovery..."
PITR=$(aws dynamodb describe-continuous-backups \
    --table-name "$TABLE_NAME" \
    --region "$REGION" \
    --query 'ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus' \
    --output text)

if [ "$PITR" == "ENABLED" ]; then
    print_status "Point-in-time recovery is enabled"
else
    print_warning "Point-in-time recovery is disabled"
fi

# Check streams
print_info "Checking DynamoDB Streams..."
STREAM_ARN=$(echo "$TABLE_INFO" | jq -r '.Table.LatestStreamArn // "null"')
if [ "$STREAM_ARN" != "null" ]; then
    print_status "Streams are enabled"
    STREAM_VIEW=$(echo "$TABLE_INFO" | jq -r '.Table.StreamSpecification.StreamViewType')
    echo -e "  Stream View Type: ${GREEN}$STREAM_VIEW${NC}"
else
    print_info "Streams are disabled"
fi

# Check indexes
print_info "Checking indexes..."
GSI_COUNT=$(echo "$TABLE_INFO" | jq '.Table.GlobalSecondaryIndexes | length')
LSI_COUNT=$(echo "$TABLE_INFO" | jq '.Table.LocalSecondaryIndexes | length')

if [ "$GSI_COUNT" == "null" ]; then
    GSI_COUNT=0
fi

if [ "$LSI_COUNT" == "null" ]; then
    LSI_COUNT=0
fi

echo -e "  Global Secondary Indexes: ${GREEN}$GSI_COUNT${NC}"
echo -e "  Local Secondary Indexes: ${GREEN}$LSI_COUNT${NC}"

# Check table size
print_info "Checking table metrics..."
ITEM_COUNT=$(echo "$TABLE_INFO" | jq -r '.Table.ItemCount')
TABLE_SIZE=$(echo "$TABLE_INFO" | jq -r '.Table.TableSizeBytes')

echo -e "  Item Count: ${GREEN}$ITEM_COUNT${NC}"
echo -e "  Table Size: ${GREEN}$(numfmt --to=iec-i --suffix=B $TABLE_SIZE 2>/dev/null || echo "$TABLE_SIZE bytes")${NC}"

# Check deletion protection
print_info "Checking deletion protection..."
DELETION_PROTECTION=$(echo "$TABLE_INFO" | jq -r '.Table.DeletionProtectionEnabled // false')
if [ "$DELETION_PROTECTION" == "true" ]; then
    print_status "Deletion protection is enabled"
else
    print_warning "Deletion protection is disabled"
fi

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "Table: ${GREEN}$TABLE_NAME${NC}"
echo -e "Status: ${GREEN}$STATUS${NC}"
echo -e "Billing: ${GREEN}$BILLING_MODE${NC}"
echo -e "Encryption: ${GREEN}$ENCRYPTION${NC}"
echo -e "PITR: ${GREEN}$PITR${NC}"
echo -e "Items: ${GREEN}$ITEM_COUNT${NC}"
echo ""

if [ "$STATUS" == "ACTIVE" ] && [ "$ENCRYPTION" == "ENABLED" ] && [ "$PITR" == "ENABLED" ]; then
    print_status "All critical checks passed!"
else
    print_warning "Some recommended configurations are missing"
fi
