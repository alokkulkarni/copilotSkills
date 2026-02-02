#!/bin/bash
# ============================================
# DynamoDB Table Deployment Script
# ============================================
# Deploy DynamoDB table with various configurations
# Usage: ./scripts/deploy-table.sh [environment] [config-file]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="${1:-dev}"
CONFIG_FILE="${2:-}"
TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_BUCKET="${TF_STATE_BUCKET:-}"
STATE_KEY="dynamodb/${ENVIRONMENT}/terraform.tfstate"
REGION="${AWS_REGION:-us-east-1}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}DynamoDB Table Deployment${NC}"
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

# Validate prerequisites
print_info "Validating prerequisites..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed"
    exit 1
fi

print_status "Prerequisites validated"

# Check AWS credentials
print_info "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_status "AWS Account: $ACCOUNT_ID"

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform
print_info "Initializing Terraform..."

if [ -n "$STATE_BUCKET" ]; then
    print_info "Using S3 backend: s3://$STATE_BUCKET/$STATE_KEY"
    terraform init \
        -backend-config="bucket=$STATE_BUCKET" \
        -backend-config="key=$STATE_KEY" \
        -backend-config="region=$REGION" \
        -backend-config="encrypt=true"
else
    print_info "Using local backend"
    terraform init
fi

print_status "Terraform initialized"

# Validate configuration
print_info "Validating Terraform configuration..."
if ! terraform validate; then
    print_error "Terraform validation failed"
    exit 1
fi
print_status "Configuration validated"

# Plan deployment
print_info "Creating deployment plan..."

PLAN_FILE="tfplan-${ENVIRONMENT}-$(date +%s)"

if [ -n "$CONFIG_FILE" ]; then
    print_info "Using config file: $CONFIG_FILE"
    terraform plan \
        -var-file="$CONFIG_FILE" \
        -out="$PLAN_FILE"
else
    terraform plan -out="$PLAN_FILE"
fi

print_status "Plan created: $PLAN_FILE"

# Display plan summary
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Deployment Plan Summary${NC}"
echo -e "${BLUE}================================================${NC}"
terraform show -no-color "$PLAN_FILE" | grep -A 3 "Plan:"

# Confirm deployment
echo ""
read -p "$(echo -e ${YELLOW}Continue with deployment? [y/N]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deployment cancelled"
    rm -f "$PLAN_FILE"
    exit 0
fi

# Apply configuration
print_info "Applying Terraform configuration..."
terraform apply "$PLAN_FILE"

# Cleanup plan file
rm -f "$PLAN_FILE"

print_status "Deployment completed successfully!"

# Display outputs
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Deployment Outputs${NC}"
echo -e "${BLUE}================================================${NC}"
terraform output

# Save outputs to file
OUTPUT_FILE="outputs-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).json"
terraform output -json > "$OUTPUT_FILE"
print_status "Outputs saved to: $OUTPUT_FILE"

echo ""
print_status "DynamoDB table deployment complete!"
