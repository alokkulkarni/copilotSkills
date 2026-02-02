# DynamoDB Table State Management Guide

Guide for configuring and managing Terraform state with S3 backend for the DynamoDB table module.

## Overview

This guide explains how to set up remote state management using AWS S3 backend with DynamoDB state locking for the DynamoDB table Terraform module.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0 installed
- Permissions to create S3 buckets and DynamoDB tables
- Permissions to create/manage IAM policies (optional, for encryption)

---

## Quick Start

### Option 1: Using Existing Backend

If your organization already has a Terraform state backend configured:

```bash
# 1. Navigate to module directory
cd aws_terraform/base_elements/dynamodb_table

# 2. Create backend configuration file
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dynamodb/your-table/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
EOF

# 3. Initialize with backend
terraform init
```

### Option 2: Create New Backend (Automated)

Use the provided script to create a new backend infrastructure:

```bash
# Run backend setup script (from repository root)
./scripts/setup-backend.sh dynamodb
```

---

## Manual Backend Setup

### Step 1: Create S3 Bucket for State Storage

```bash
# Set variables
BUCKET_NAME="my-terraform-state-bucket"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create S3 bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
    IgnorePublicAcls=true,\
    BlockPublicPolicy=true,\
    RestrictPublicBuckets=true

# Enable bucket logging (optional)
aws s3api put-bucket-logging \
  --bucket $BUCKET_NAME \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "'$BUCKET_NAME'",
      "TargetPrefix": "logs/"
    }
  }'
```

### Step 2: Create DynamoDB Table for State Locking

```bash
# Create state lock table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

# Enable point-in-time recovery
aws dynamodb update-continuous-backups \
  --table-name terraform-state-lock \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true

# Add tags
aws dynamodb tag-resource \
  --resource-arn arn:aws:dynamodb:$REGION:$ACCOUNT_ID:table/terraform-state-lock \
  --tags Key=Purpose,Value=TerraformStateLock Key=ManagedBy,Value=Terraform
```

### Step 3: Configure Terraform Backend

Create a `backend.tf` file in the module directory:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dynamodb/my-table/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Optional: Use KMS for encryption
    # kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
  }
}
```

### Step 4: Initialize Backend

```bash
# Initialize Terraform with new backend
terraform init

# If migrating from local state
terraform init -migrate-state
```

---

## Backend Configuration Options

### Basic Configuration

Minimal backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dynamodb/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Production Configuration

Recommended for production environments:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dynamodb/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
    
    # Workspace isolation
    workspace_key_prefix = "workspaces"
    
    # Access control
    acl = "private"
    
    # Assume role (if using cross-account)
    # role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformRole"
  }
}
```

### Multi-Environment Configuration

Use different state paths for different environments:

```hcl
# Development
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dynamodb/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

# Production
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dynamodb/prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Using Backend Configuration with CLI

### Initialize with Backend Config File

```bash
# Create backend config file
cat > backend-config.hcl <<EOF
bucket         = "my-terraform-state-bucket"
key            = "dynamodb/my-table/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"
EOF

# Initialize using config file
terraform init -backend-config=backend-config.hcl
```

### Initialize with Environment Variables

```bash
# Set environment variables
export TF_CLI_ARGS_init="-backend-config='bucket=my-terraform-state-bucket' \
  -backend-config='key=dynamodb/my-table/terraform.tfstate' \
  -backend-config='region=us-east-1' \
  -backend-config='encrypt=true' \
  -backend-config='dynamodb_table=terraform-state-lock'"

# Initialize
terraform init
```

### Initialize with Command-Line Arguments

```bash
terraform init \
  -backend-config="bucket=my-terraform-state-bucket" \
  -backend-config="key=dynamodb/my-table/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=terraform-state-lock"
```

---

## State Management Operations

### View Current State

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_dynamodb_table.this

# Show all state
terraform show
```

### Pull State File

```bash
# Download current state
terraform state pull > terraform.tfstate.backup

# View state in JSON format
terraform state pull | jq '.'
```

### Push State File

```bash
# Upload modified state (use with caution!)
terraform state push terraform.tfstate
```

### Migrate State Between Backends

```bash
# Scenario: Moving from local to S3 backend

# Step 1: Backup current state
terraform state pull > local-state-backup.json

# Step 2: Add backend configuration
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dynamodb/terraform.tfstate"
    region = "us-east-1"
  }
}
EOF

# Step 3: Initialize and migrate
terraform init -migrate-state

# Step 4: Verify migration
terraform state list
```

### Remove Resource from State

```bash
# Remove resource without destroying it
terraform state rm aws_dynamodb_table.this

# Remove multiple resources
terraform state rm aws_dynamodb_table.this aws_iam_policy.lambda_dynamodb_access
```

### Import Existing Resources

```bash
# Import existing DynamoDB table
terraform import aws_dynamodb_table.this users-table

# Import IAM policy
terraform import aws_iam_policy.lambda_dynamodb_access arn:aws:iam::ACCOUNT_ID:policy/policy-name
```

---

## State Locking

### Understanding State Locking

DynamoDB is used to prevent concurrent Terraform operations:

```bash
# Lock is automatically acquired during operations
terraform apply  # Acquires lock

# Lock is released after operation completes
# or when interrupted (Ctrl+C)
```

### Force Unlock (Emergency Only)

```bash
# If lock is stuck, force unlock
terraform force-unlock <lock-id>

# Example
terraform force-unlock 1234567890abcdef
```

### View Lock Status

```bash
# Check DynamoDB for active locks
aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "attribute_exists(LockID)"
```

---

## Workspace Management

### Create and Use Workspaces

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new production

# Switch workspace
terraform workspace select dev

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete dev
```

### Workspace-Specific State Paths

When using workspaces, state files are organized as:

```
s3://bucket-name/
  └── workspaces/
      ├── dev/
      │   └── dynamodb/terraform.tfstate
      ├── staging/
      │   └── dynamodb/terraform.tfstate
      └── production/
          └── dynamodb/terraform.tfstate
```

---

## Backup and Recovery

### Manual State Backup

```bash
# Create timestamped backup
terraform state pull > "backups/terraform-$(date +%Y%m%d-%H%M%S).tfstate"

# Verify backup
cat backups/terraform-*.tfstate | jq '.resources | length'
```

### Automated Backup Script

```bash
#!/bin/bash
# backup-state.sh

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/terraform-$TIMESTAMP.tfstate"

mkdir -p $BACKUP_DIR

echo "Backing up Terraform state..."
terraform state pull > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Backup saved: $BACKUP_FILE"
    # Keep only last 10 backups
    ls -t $BACKUP_DIR/terraform-*.tfstate | tail -n +11 | xargs -r rm
else
    echo "Backup failed!"
    exit 1
fi
```

### Restore from Backup

```bash
# Step 1: Download backup
aws s3 cp s3://my-terraform-state-bucket/dynamodb/terraform.tfstate.backup ./

# Step 2: Push backup to current state
terraform state push terraform.tfstate.backup

# Step 3: Verify restoration
terraform state list
terraform plan  # Should show no changes if restore is successful
```

### Use S3 Versioning for Recovery

```bash
# List all versions of state file
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix dynamodb/terraform.tfstate

# Restore specific version
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key dynamodb/terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate.restored

# Push restored state
terraform state push terraform.tfstate.restored
```

---

## Troubleshooting

### Issue 1: State Lock Timeout

**Error:** `Error acquiring state lock`

```bash
# Check for active locks
aws dynamodb scan --table-name terraform-state-lock

# Force unlock (use carefully)
terraform force-unlock <lock-id>

# If lock table doesn't exist
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Issue 2: Backend Initialization Failed

**Error:** `Error configuring S3 Backend`

```bash
# Verify bucket exists
aws s3 ls s3://my-terraform-state-bucket

# Verify AWS credentials
aws sts get-caller-identity

# Check bucket permissions
aws s3api get-bucket-policy --bucket my-terraform-state-bucket

# Re-initialize
terraform init -reconfigure
```

### Issue 3: State File Corruption

**Error:** `Failed to load state`

```bash
# Download current state
terraform state pull > current-state.json

# Validate JSON
cat current-state.json | jq '.'

# If invalid, restore from backup
aws s3 cp s3://my-terraform-state-bucket/dynamodb/terraform.tfstate.backup ./
terraform state push terraform.tfstate.backup

# If no backup, restore from S3 versioning
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix dynamodb/terraform.tfstate \
  --query 'Versions[0].VersionId' \
  --output text
```

### Issue 4: State Drift Detection

**Symptom:** Terraform detects changes that weren't applied

```bash
# Check for drift
terraform plan -detailed-exitcode
# Exit code 2 = changes detected

# Refresh state from actual infrastructure
terraform refresh

# If resource was modified outside Terraform
# Option 1: Update Terraform config to match reality
# Option 2: Re-apply Terraform config to fix drift
terraform apply
```

---

## Security Best Practices

### 1. Enable State File Encryption

```bash
# Server-side encryption with S3-managed keys
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Server-side encryption with KMS
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:region:account:key/key-id"
      }
    }]
  }'
```

### 2. Restrict Bucket Access

```bash
# Create bucket policy
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-terraform-state-bucket/*",
        "arn:aws:s3:::my-terraform-state-bucket"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF

# Apply policy
aws s3api put-bucket-policy \
  --bucket my-terraform-state-bucket \
  --policy file://bucket-policy.json
```

### 3. Enable Access Logging

```bash
# Create logging bucket
aws s3api create-bucket \
  --bucket my-terraform-state-logs \
  --region us-east-1

# Enable logging
aws s3api put-bucket-logging \
  --bucket my-terraform-state-bucket \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "my-terraform-state-logs",
      "TargetPrefix": "state-access-logs/"
    }
  }'
```

### 4. Use IAM Policies for Access Control

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-bucket"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

---

## Monitoring and Auditing

### CloudTrail for State Access

```bash
# Enable CloudTrail for S3 data events
aws cloudtrail put-event-selectors \
  --trail-name my-trail \
  --event-selectors '[{
    "ReadWriteType": "All",
    "IncludeManagementEvents": true,
    "DataResources": [{
      "Type": "AWS::S3::Object",
      "Values": ["arn:aws:s3:::my-terraform-state-bucket/*"]
    }]
  }]'
```

### CloudWatch Alarms

```bash
# Create alarm for state file changes
aws cloudwatch put-metric-alarm \
  --alarm-name terraform-state-modified \
  --alarm-description "Alert when Terraform state is modified" \
  --metric-name NumberOfObjects \
  --namespace AWS/S3 \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=BucketName,Value=my-terraform-state-bucket \
                Name=StorageType,Value=AllStorageTypes
```

---

## Reference

### Required IAM Permissions

Minimum permissions for Terraform state management:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::BUCKET_NAME"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::BUCKET_NAME/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

---

For additional information, refer to [README.md](./README.md) and [OPERATIONS_GUIDE.md](./OPERATIONS_GUIDE.md).
