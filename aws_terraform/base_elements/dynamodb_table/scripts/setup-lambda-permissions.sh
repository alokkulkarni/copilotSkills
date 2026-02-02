#!/bin/bash
# ============================================
# Lambda-DynamoDB Permission Setup Script
# ============================================
# Grant Lambda function permissions to access DynamoDB table
# Usage: ./scripts/setup-lambda-permissions.sh [table-name] [lambda-function-names]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
TABLE_NAME="${1}"
LAMBDA_FUNCTIONS="${2}"
REGION="${AWS_REGION:-us-east-1}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Lambda-DynamoDB Permission Setup${NC}"
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
    echo "Usage: $0 <table-name> <lambda-function-names>"
    echo "Example: $0 users-table 'lambda1,lambda2,lambda3'"
    exit 1
fi

if [ -z "$LAMBDA_FUNCTIONS" ]; then
    print_error "Lambda function names are required"
    echo "Usage: $0 <table-name> <lambda-function-names>"
    echo "Example: $0 users-table 'lambda1,lambda2,lambda3'"
    exit 1
fi

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_info "AWS Account: $ACCOUNT_ID"
print_info "Region: $REGION"

# Get table ARN
print_info "Retrieving table ARN for: $TABLE_NAME"
TABLE_ARN=$(aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --region "$REGION" \
    --query 'Table.TableArn' \
    --output text)

if [ -z "$TABLE_ARN" ]; then
    print_error "Table not found: $TABLE_NAME"
    exit 1
fi

print_status "Table ARN: $TABLE_ARN"

# Create IAM policy
POLICY_NAME="${TABLE_NAME}-lambda-access-$(date +%s)"
POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:ConditionCheckItem"
      ],
      "Resource": [
        "${TABLE_ARN}",
        "${TABLE_ARN}/index/*"
      ]
    }
  ]
}
EOF
)

print_info "Creating IAM policy: $POLICY_NAME"
POLICY_ARN=$(aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --policy-document "$POLICY_DOCUMENT" \
    --query 'Policy.Arn' \
    --output text)

print_status "Policy created: $POLICY_ARN"

# Attach policy to Lambda function roles
IFS=',' read -ra LAMBDA_ARRAY <<< "$LAMBDA_FUNCTIONS"

for LAMBDA_NAME in "${LAMBDA_ARRAY[@]}"; do
    LAMBDA_NAME=$(echo "$LAMBDA_NAME" | xargs) # Trim whitespace
    
    print_info "Processing Lambda function: $LAMBDA_NAME"
    
    # Get Lambda role ARN
    ROLE_ARN=$(aws lambda get-function \
        --function-name "$LAMBDA_NAME" \
        --region "$REGION" \
        --query 'Configuration.Role' \
        --output text)
    
    if [ -z "$ROLE_ARN" ]; then
        print_error "Lambda function not found: $LAMBDA_NAME"
        continue
    fi
    
    # Extract role name from ARN
    ROLE_NAME=$(echo "$ROLE_ARN" | awk -F'/' '{print $NF}')
    
    print_info "Attaching policy to role: $ROLE_NAME"
    
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "$POLICY_ARN"
    
    print_status "Policy attached to $LAMBDA_NAME"
done

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Permission Setup Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "Table: ${GREEN}$TABLE_NAME${NC}"
echo -e "Policy ARN: ${GREEN}$POLICY_ARN${NC}"
echo -e "Lambda Functions: ${GREEN}${#LAMBDA_ARRAY[@]}${NC}"
echo ""

for LAMBDA_NAME in "${LAMBDA_ARRAY[@]}"; do
    LAMBDA_NAME=$(echo "$LAMBDA_NAME" | xargs)
    echo -e "  ${GREEN}✓${NC} $LAMBDA_NAME"
done

echo ""
print_status "Permission setup completed successfully!"

# Save configuration
CONFIG_FILE="lambda-permissions-${TABLE_NAME}-$(date +%Y%m%d-%H%M%S).json"
cat > "$CONFIG_FILE" <<EOF
{
  "table_name": "$TABLE_NAME",
  "table_arn": "$TABLE_ARN",
  "policy_name": "$POLICY_NAME",
  "policy_arn": "$POLICY_ARN",
  "lambda_functions": [$(printf '"%s",' "${LAMBDA_ARRAY[@]}" | sed 's/,$//')]
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

print_status "Configuration saved to: $CONFIG_FILE"
