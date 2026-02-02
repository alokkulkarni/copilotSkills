#!/bin/bash
# ============================================
# DynamoDB Backup Script
# ============================================
# Create on-demand backup of DynamoDB table
# Usage: ./scripts/backup-table.sh [table-name] [backup-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
TABLE_NAME="${1}"
BACKUP_NAME="${2:-backup-$(date +%Y%m%d-%H%M%S)}"
REGION="${AWS_REGION:-us-east-1}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}DynamoDB Table Backup${NC}"
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
    echo "Usage: $0 <table-name> [backup-name]"
    exit 1
fi

print_info "Table: $TABLE_NAME"
print_info "Backup name: $BACKUP_NAME"
print_info "Region: $REGION"

# Verify table exists
print_info "Verifying table exists..."
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &> /dev/null; then
    print_error "Table not found: $TABLE_NAME"
    exit 1
fi
print_status "Table verified"

# Create backup
print_info "Creating backup..."
BACKUP_ARN=$(aws dynamodb create-backup \
    --table-name "$TABLE_NAME" \
    --backup-name "$BACKUP_NAME" \
    --region "$REGION" \
    --query 'BackupDetails.BackupArn' \
    --output text)

if [ -z "$BACKUP_ARN" ]; then
    print_error "Failed to create backup"
    exit 1
fi

print_status "Backup created: $BACKUP_ARN"

# Wait for backup to complete
print_info "Waiting for backup to complete..."
while true; do
    STATUS=$(aws dynamodb describe-backup \
        --backup-arn "$BACKUP_ARN" \
        --region "$REGION" \
        --query 'BackupDescription.BackupDetails.BackupStatus' \
        --output text)
    
    if [ "$STATUS" == "AVAILABLE" ]; then
        print_status "Backup completed successfully"
        break
    elif [ "$STATUS" == "CREATING" ]; then
        echo -n "."
        sleep 5
    else
        print_error "Backup failed with status: $STATUS"
        exit 1
    fi
done

# Get backup details
BACKUP_SIZE=$(aws dynamodb describe-backup \
    --backup-arn "$BACKUP_ARN" \
    --region "$REGION" \
    --query 'BackupDescription.BackupDetails.BackupSizeBytes' \
    --output text)

BACKUP_TIME=$(aws dynamodb describe-backup \
    --backup-arn "$BACKUP_ARN" \
    --region "$REGION" \
    --query 'BackupDescription.BackupDetails.BackupCreationDateTime' \
    --output text)

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Backup Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "Table: ${GREEN}$TABLE_NAME${NC}"
echo -e "Backup Name: ${GREEN}$BACKUP_NAME${NC}"
echo -e "Backup ARN: ${GREEN}$BACKUP_ARN${NC}"
echo -e "Size: ${GREEN}$(numfmt --to=iec-i --suffix=B $BACKUP_SIZE)${NC}"
echo -e "Created: ${GREEN}$(date -d @$BACKUP_TIME)${NC}"
echo ""

print_status "Backup operation completed successfully!"
