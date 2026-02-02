# DynamoDB Table Operations Guide

Comprehensive step-by-step guide for common DynamoDB table operations.

## Table of Contents

- [Initial Setup](#initial-setup)
- [Table Deployment](#table-deployment)
- [Lambda Integration](#lambda-integration)
- [Data Population](#data-population)
- [Backup Operations](#backup-operations)
- [Monitoring and Validation](#monitoring-and-validation)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## Initial Setup

### Prerequisites Check

```bash
# 1. Verify Terraform installation
terraform version
# Expected: Terraform v1.5.0 or later

# 2. Verify AWS CLI installation
aws --version
# Expected: aws-cli/2.x.x or later

# 3. Verify AWS credentials
aws sts get-caller-identity
# Should return your AWS account details

# 4. Check jq installation (for data population scripts)
jq --version
# Expected: jq-1.6 or later
```

### Environment Setup

```bash
# 1. Clone or navigate to repository
cd aws_terraform/base_elements/dynamodb_table

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Set AWS region (optional)
export AWS_REGION=us-east-1

# 4. Set Terraform state bucket (optional)
export TF_STATE_BUCKET=my-terraform-state-bucket
```

---

## Table Deployment

### Scenario 1: Deploy Simple On-Demand Table

**Use Case:** Development environment with unpredictable workload

```bash
# Step 1: Review configuration
cat examples/simple-table.tfvars

# Step 2: Initialize Terraform
terraform init

# Step 3: Validate configuration
terraform validate

# Step 4: Preview changes
terraform plan -var-file="examples/simple-table.tfvars"

# Step 5: Deploy table
terraform apply -var-file="examples/simple-table.tfvars"

# Step 6: Verify outputs
terraform output
```

**Alternative: Using Deployment Script**

```bash
./scripts/deploy-table.sh dev examples/simple-table.tfvars
```

### Scenario 2: Deploy Table with Global Secondary Index

**Use Case:** Need alternate query patterns (e.g., query by category)

```bash
# Step 1: Review GSI configuration
cat examples/table-with-gsi.tfvars

# Step 2: Deploy table with GSI
terraform apply -var-file="examples/table-with-gsi.tfvars"

# Step 3: Verify GSI creation
aws dynamodb describe-table \
  --table-name products-table \
  --query 'Table.GlobalSecondaryIndexes'
```

### Scenario 3: Deploy Provisioned Table with Auto-Scaling

**Use Case:** Production workload with predictable traffic patterns

```bash
# Step 1: Review provisioned configuration
cat examples/provisioned-autoscaling.tfvars

# Step 2: Deploy table
terraform apply -var-file="examples/provisioned-autoscaling.tfvars"

# Step 3: Verify auto-scaling targets
aws application-autoscaling describe-scalable-targets \
  --service-namespace dynamodb

# Step 4: Verify auto-scaling policies
aws application-autoscaling describe-scaling-policies \
  --service-namespace dynamodb
```

### Scenario 4: Deploy Global Table

**Use Case:** Multi-region application requiring low latency globally

```bash
# Step 1: Review global table configuration
cat examples/global-table.tfvars

# Step 2: Deploy primary table
terraform apply -var-file="examples/global-table.tfvars"

# Step 3: Verify replicas
aws dynamodb describe-table \
  --table-name global-users-table \
  --query 'Table.Replicas'

# Step 4: Test replication (write in one region, read in another)
aws dynamodb put-item \
  --table-name global-users-table \
  --item '{"userId": {"S": "test-user"}}'

aws dynamodb get-item \
  --table-name global-users-table \
  --key '{"userId": {"S": "test-user"}}' \
  --region eu-west-1
```

---

## Lambda Integration

### Scenario 5: Enable DynamoDB Streams with Lambda Trigger

**Use Case:** Process table changes in real-time

```bash
# Step 1: Ensure Lambda function exists
aws lambda get-function --function-name order-processing-lambda

# Step 2: Review stream configuration
cat examples/table-with-lambda.tfvars

# Step 3: Deploy table with streams
terraform apply -var-file="examples/table-with-lambda.tfvars"

# Step 4: Verify event source mapping
aws lambda list-event-source-mappings \
  --function-name order-processing-lambda

# Step 5: Test stream processing
# Write an item to trigger Lambda
aws dynamodb put-item \
  --table-name orders-table \
  --item '{"orderId": {"S": "order-123"}, "amount": {"N": "99.99"}}'

# Step 6: Check Lambda logs
aws logs tail /aws/lambda/order-processing-lambda --follow
```

### Scenario 6: Grant Lambda Access to Existing Table

**Use Case:** Add Lambda permissions to already deployed table

```bash
# Method 1: Using Setup Script
./scripts/setup-lambda-permissions.sh users-table "lambda1,lambda2,lambda3"

# Method 2: Using Terraform
# Update your tfvars file:
# create_lambda_access_policy = true
# lambda_function_names       = ["lambda1", "lambda2", "lambda3"]

terraform apply \
  -target=aws_iam_policy.lambda_dynamodb_access \
  -target=aws_iam_role_policy_attachment.lambda_dynamodb_access

# Verify policy attachment
aws iam list-attached-role-policies \
  --role-name <lambda-role-name>
```

---

## Data Population

### Scenario 7: Populate Table with Initial Data

**Use Case:** Seed table with configuration or test data

#### Method 1: Using Terraform-Managed Items (Small Static Data)

```bash
# Step 1: Update tfvars with terraform_managed_items
cat > config-data.tfvars <<EOF
table_name   = "config-table"
hash_key     = "configKey"
# ... other settings ...

use_terraform_items = true
terraform_managed_items = {
  app_settings = {
    configKey = { S = "app_settings" }
    configValue = { S = "{\"theme\":\"dark\"}" }
  }
}
EOF

# Step 2: Deploy with data
terraform apply -var-file="config-data.tfvars"
```

#### Method 2: Using Batch Write Script (Bulk Data)

```bash
# Step 1: Prepare data file
cat > data/users.json <<EOF
[
  {
    "userId": {"S": "user1"},
    "name": {"S": "John Doe"},
    "email": {"S": "john@example.com"},
    "createdAt": {"N": "1704067200"}
  },
  {
    "userId": {"S": "user2"},
    "name": {"S": "Jane Smith"},
    "email": {"S": "jane@example.com"},
    "createdAt": {"N": "1704067200"}
  }
]
EOF

# Step 2: Run population script
./scripts/populate-data.sh users-table data/users.json

# Step 3: Verify data insertion
aws dynamodb scan --table-name users-table --max-items 5
```

#### Method 3: Using AWS CLI (Single Items)

```bash
# Insert single item
aws dynamodb put-item \
  --table-name users-table \
  --item '{
    "userId": {"S": "user3"},
    "name": {"S": "Bob Johnson"},
    "email": {"S": "bob@example.com"}
  }'

# Verify insertion
aws dynamodb get-item \
  --table-name users-table \
  --key '{"userId": {"S": "user3"}}'
```

---

## Backup Operations

### Scenario 8: Enable Automated Backups

**Use Case:** Compliance requirement for daily backups

```bash
# Step 1: Review backup configuration
cat examples/table-with-backup.tfvars

# Step 2: Deploy backup configuration
terraform apply \
  -target=aws_backup_vault.dynamodb \
  -target=aws_backup_plan.dynamodb \
  -target=aws_backup_selection.dynamodb

# Step 3: Verify backup plan
aws backup list-backup-plans

# Step 4: Verify backup selection
aws backup list-backup-selections \
  --backup-plan-id <plan-id-from-step-3>
```

### Scenario 9: Create On-Demand Backup

**Use Case:** Backup before major update or migration

```bash
# Method 1: Using Backup Script
./scripts/backup-table.sh users-table backup-before-migration

# Method 2: Using Terraform
# Update tfvars:
# create_manual_backup = true

terraform apply -target=aws_dynamodb_table_backup.manual

# Method 3: Using AWS CLI
aws dynamodb create-backup \
  --table-name users-table \
  --backup-name manual-backup-$(date +%Y%m%d-%H%M%S)

# Verify backup
aws dynamodb list-backups --table-name users-table
```

### Scenario 10: Restore from Backup

**Use Case:** Recover from accidental data deletion

```bash
# Step 1: List available backups
aws dynamodb list-backups --table-name users-table

# Step 2: Restore to new table
aws dynamodb restore-table-from-backup \
  --target-table-name users-table-restored \
  --backup-arn <backup-arn-from-step-1>

# Step 3: Wait for restoration
aws dynamodb describe-table \
  --table-name users-table-restored \
  --query 'Table.TableStatus'

# Step 4: Verify restored data
aws dynamodb scan --table-name users-table-restored --max-items 5

# Step 5: (Optional) Point-in-Time Recovery
aws dynamodb restore-table-to-point-in-time \
  --source-table-name users-table \
  --target-table-name users-table-pitr-restore \
  --restore-date-time "2026-02-01T12:00:00Z"
```

---

## Monitoring and Validation

### Scenario 11: Validate Table Configuration

**Use Case:** Verify table is configured correctly

```bash
# Method 1: Using Validation Script
./scripts/validate-table.sh users-table

# Method 2: Manual Checks
# Check table status
aws dynamodb describe-table \
  --table-name users-table \
  --query 'Table.TableStatus'

# Check encryption
aws dynamodb describe-table \
  --table-name users-table \
  --query 'Table.SSEDescription'

# Check point-in-time recovery
aws dynamodb describe-continuous-backups \
  --table-name users-table

# Check streams
aws dynamodb describe-table \
  --table-name users-table \
  --query 'Table.StreamSpecification'
```

### Scenario 12: Monitor Table Metrics

**Use Case:** Track table performance and usage

```bash
# Get table metrics for last hour
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=users-table \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Get write capacity metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=users-table \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Get throttled requests
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name UserErrors \
  --dimensions Name=TableName,Value=users-table \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

---

## Troubleshooting

### Issue 1: Throttling Errors

**Symptoms:** ProvisionedThroughputExceededException errors

```bash
# Diagnosis: Check throttled requests
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ThrottledRequests \
  --dimensions Name=TableName,Value=users-table \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Solution 1: Switch to on-demand billing
# Update tfvars: billing_mode = "PAY_PER_REQUEST"
terraform apply

# Solution 2: Enable auto-scaling
# Update tfvars: enable_autoscaling = true
terraform apply -target=aws_appautoscaling_target.table_read \
  -target=aws_appautoscaling_target.table_write
```

### Issue 2: Lambda Not Triggered by Streams

**Symptoms:** Items written but Lambda not executing

```bash
# Diagnosis
# 1. Verify streams are enabled
aws dynamodb describe-table \
  --table-name orders-table \
  --query 'Table.StreamSpecification'

# 2. Verify event source mapping
aws lambda list-event-source-mappings \
  --function-name order-processing-lambda

# 3. Check event source mapping state
aws lambda get-event-source-mapping \
  --uuid <mapping-uuid-from-step-2>

# Solution 1: Check Lambda permissions
aws lambda get-policy --function-name order-processing-lambda

# Solution 2: Enable event source mapping if disabled
aws lambda update-event-source-mapping \
  --uuid <mapping-uuid> \
  --enabled

# Solution 3: Check Lambda CloudWatch logs
aws logs tail /aws/lambda/order-processing-lambda --follow
```

### Issue 3: Backup Failed

**Symptoms:** Backup job shows FAILED status

```bash
# Diagnosis
# 1. List recent backup jobs
aws backup list-backup-jobs \
  --by-resource-arn <table-arn> \
  --max-results 10

# 2. Describe failed job
aws backup describe-backup-job \
  --backup-job-id <job-id-from-step-1>

# Solution 1: Check IAM permissions
aws iam get-role-policy \
  --role-name <backup-role-name> \
  --policy-name <policy-name>

# Solution 2: Verify table exists and is ACTIVE
aws dynamodb describe-table --table-name users-table

# Solution 3: Retry backup
./scripts/backup-table.sh users-table retry-backup
```

---

## Cleanup

### Scenario 13: Remove Table and Associated Resources

**Use Case:** Decommission table and clean up resources

```bash
# Step 1: Disable deletion protection
# Update tfvars: deletion_protection = false
terraform apply -target=aws_dynamodb_table.this

# Step 2: (Optional) Create final backup
./scripts/backup-table.sh users-table final-backup

# Step 3: Destroy specific components
# Remove streams first
terraform destroy -target=aws_lambda_event_source_mapping.dynamodb_stream

# Remove auto-scaling
terraform destroy -target=aws_appautoscaling_target.table_read \
  -target=aws_appautoscaling_target.table_write

# Remove backups
terraform destroy -target=aws_backup_selection.dynamodb \
  -target=aws_backup_plan.dynamodb \
  -target=aws_backup_vault.dynamodb

# Step 4: Destroy table
terraform destroy -target=aws_dynamodb_table.this

# Step 5: Clean up IAM policies
terraform destroy -target=aws_iam_policy.lambda_dynamodb_access
```

### Scenario 14: Export Table Data Before Deletion

**Use Case:** Preserve data before decommissioning

```bash
# Export full table to JSON
aws dynamodb scan \
  --table-name users-table \
  --output json > backup/users-table-export-$(date +%Y%m%d).json

# Export to S3 (for large tables)
aws dynamodb export-table-to-point-in-time \
  --table-arn <table-arn> \
  --s3-bucket my-exports-bucket \
  --s3-prefix dynamodb-exports/ \
  --export-format DYNAMODB_JSON

# Monitor export status
aws dynamodb describe-export \
  --export-arn <export-arn-from-previous-command>
```

---

## Quick Reference

### Common Commands

```bash
# Deploy everything
terraform apply

# Deploy only table
terraform apply -target=aws_dynamodb_table.this

# Deploy with specific configuration
terraform apply -var-file="examples/simple-table.tfvars"

# Validate configuration
./scripts/validate-table.sh <table-name>

# Setup Lambda permissions
./scripts/setup-lambda-permissions.sh <table-name> "lambda1,lambda2"

# Populate data
./scripts/populate-data.sh <table-name> <data-file>

# Create backup
./scripts/backup-table.sh <table-name>

# View outputs
terraform output

# Destroy everything
terraform destroy
```

### Terraform State Commands

```bash
# List resources
terraform state list

# Show resource details
terraform state show aws_dynamodb_table.this

# Remove resource from state (without destroying)
terraform state rm aws_dynamodb_table.this

# Import existing table
terraform import aws_dynamodb_table.this users-table
```

---

## Best Practices Checklist

- [ ] Enable encryption at rest
- [ ] Enable point-in-time recovery for production tables
- [ ] Configure automated backups for compliance
- [ ] Use auto-scaling for provisioned tables
- [ ] Enable deletion protection for critical tables
- [ ] Tag all resources consistently
- [ ] Monitor CloudWatch metrics regularly
- [ ] Test restore procedures periodically
- [ ] Use least-privilege IAM policies
- [ ] Enable CloudTrail for audit logging
- [ ] Document table schema and access patterns
- [ ] Implement TTL for temporary data
- [ ] Use appropriate billing mode for workload

---

For additional information, refer to [README.md](./README.md) and [STATE_MANAGEMENT.md](./STATE_MANAGEMENT.md).
