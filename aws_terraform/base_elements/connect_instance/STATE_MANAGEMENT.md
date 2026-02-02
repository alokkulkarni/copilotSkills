# Terraform State Management with S3

Complete guide for managing Terraform state in S3 for the Connect Instance module.

## Prerequisites

- AWS CLI installed and configured
- S3 bucket created for state storage
- DynamoDB table for state locking
- Proper IAM permissions

## Initial Setup

### 1. Create S3 Bucket for State

```bash
# Create state bucket with versioning
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

# Enable versioning (critical for recovery)
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket my-terraform-state-bucket \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable lifecycle policy for old versions
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-terraform-state-bucket \
  --lifecycle-configuration '{
    "Rules": [{
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 90
      }
    }]
  }'
```

### 2. Create DynamoDB Table for Locking

```bash
# Create lock table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-2

# Wait for table to be active
aws dynamodb wait table-exists --table-name terraform-state-lock

# Verify table
aws dynamodb describe-table \
  --table-name terraform-state-lock \
  --query 'Table.TableStatus'
```

### 3. Configure Backend in Terraform

Create `backend.tf` in your root module (not in the base_elements module):

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "connect-instance/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Optional but recommended
    workspace_key_prefix = "workspaces"
  }
}
```

### 4. Initialize Backend

```bash
# Initialize Terraform with S3 backend
terraform init

# Migrate existing local state (if applicable)
terraform init -migrate-state

# Verify backend configuration
terraform show
```

## State Verification Checklist

### Before Operations

```bash
# 1. Verify S3 bucket exists
aws s3 ls s3://my-terraform-state-bucket/

# 2. Check state file exists
aws s3 ls s3://my-terraform-state-bucket/connect-instance/terraform.tfstate

# 3. Verify DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock --query 'Table.TableStatus'

# 4. Check for existing locks
aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "contains(LockID, :key)" \
  --expression-attribute-values '{":key":{"S":"connect-instance"}}'

# 5. Verify Terraform state integrity
terraform state list
```

### During Operations

```bash
# Monitor state file changes
watch -n 5 'aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --query LastModified \
  --output text'

# Check lock status
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}'
```

### After Operations

```bash
# 1. Verify state was updated
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --query '[LastModified,ETag,VersionId]' \
  --output table

# 2. Check state file size (detect corruption)
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --query 'ContentLength'

# 3. Verify no active locks remain
aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "contains(LockID, :key)" \
  --expression-attribute-values '{":key":{"S":"connect-instance"}}' \
  --query 'Count'

# 4. Validate state integrity
terraform state list > /dev/null && echo "State is valid" || echo "State corrupted!"

# 5. Compare resources in state vs AWS
terraform plan -detailed-exitcode
```

## State Maintenance

### Daily Maintenance

```bash
# Check state health
terraform state list | wc -l  # Count resources
terraform plan -detailed-exitcode  # Check for drift

# Verify S3 state
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate
```

### Weekly Maintenance

```bash
# Review state versions
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --max-items 20 \
  --query 'Versions[*].[LastModified,Size,VersionId]' \
  --output table

# Check DynamoDB usage
aws dynamodb describe-table \
  --table-name terraform-state-lock \
  --query 'Table.[ItemCount,TableSizeBytes]'

# Audit state access
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=my-terraform-state-bucket \
  --max-results 50 \
  --query 'Events[?contains(EventName, `GetObject`) || contains(EventName, `PutObject`)]'
```

### Monthly Maintenance

```bash
# Create manual backup
terraform state pull > "backups/connect-$(date +%Y%m%d).tfstate"

# Review old versions (lifecycle cleanup)
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[?LastModified<=`2024-01-01`]' \
  --output table

# Test disaster recovery
# (Download previous version and verify it's readable)
BACKUP_VERSION=$(aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[1].VersionId' \
  --output text)

aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id $BACKUP_VERSION \
  test-recovery.tfstate

terraform state list -state=test-recovery.tfstate
rm test-recovery.tfstate
```

## Common State Issues

### Issue: State File Missing

```bash
# Symptoms
terraform init  # Works
terraform plan  # Error: Failed to get existing workspaces

# Check S3
aws s3 ls s3://my-terraform-state-bucket/connect-instance/

# Solution 1: Restore from version
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate

# Get latest version
LATEST_VERSION=$(aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[0].VersionId' \
  --output text)

# Restore
aws s3api copy-object \
  --copy-source "my-terraform-state-bucket/connect-instance/terraform.tfstate?versionId=$LATEST_VERSION" \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate
```

### Issue: State Lock Won't Release

```bash
# Symptoms
terraform plan  # Error: Error acquiring state lock

# Check lock
LOCK_ID=$(aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}' \
  --query 'Item.LockID.S' \
  --output text)

# Get lock details
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}' \
  --query 'Item.Info.S' \
  --output text | jq .

# Solution 1: Wait for automatic release (10 minutes)
# Solution 2: Force unlock (if you're sure no one else is running)
terraform force-unlock $LOCK_ID

# Solution 3: Manual DynamoDB deletion (extreme caution)
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}'
```

### Issue: State Drift Detected

```bash
# Symptoms
terraform plan  # Shows unexpected changes

# Diagnose
terraform plan -out=drift.tfplan
terraform show drift.tfplan > drift-details.txt

# Solution 1: Accept drift and update state
terraform apply

# Solution 2: Revert AWS changes to match state
# (manually or via AWS console)

# Solution 3: Refresh state to match AWS
terraform refresh
terraform plan  # Should show no changes now
```

### Issue: State Corruption

```bash
# Symptoms
terraform state list  # Error or unexpected output

# Verify corruption
terraform state pull > current.tfstate
cat current.tfstate | jq . > /dev/null
echo $?  # Non-zero = corrupted JSON

# Solution: Restore from S3 version
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[*].[LastModified,VersionId]' \
  --output table

# Download known-good version
GOOD_VERSION="<version-id-from-above>"
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id $GOOD_VERSION \
  recovered.tfstate

# Verify it's valid
terraform state list -state=recovered.tfstate

# Push to replace current
terraform state push recovered.tfstate
```

## State Security

### Encryption at Rest

```bash
# Verify S3 encryption
aws s3api get-bucket-encryption \
  --bucket my-terraform-state-bucket

# Verify state file is encrypted
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --query 'ServerSideEncryption'
```

### Access Control

```bash
# List bucket policies
aws s3api get-bucket-policy \
  --bucket my-terraform-state-bucket

# Recommended bucket policy
cat > state-bucket-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireEncryptedTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-terraform-state-bucket",
        "arn:aws:s3:::my-terraform-state-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "RequireEncryptedStorage",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-terraform-state-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-policy \
  --bucket my-terraform-state-bucket \
  --policy file://state-bucket-policy.json
```

### Audit Logging

```bash
# Enable S3 access logging
aws s3api put-bucket-logging \
  --bucket my-terraform-state-bucket \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "my-logging-bucket",
      "TargetPrefix": "state-access-logs/"
    }
  }'

# Query CloudTrail for state access
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=my-terraform-state-bucket \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --query 'Events[*].[EventTime,EventName,Username]' \
  --output table
```

## Disaster Recovery

### Backup Strategy

```bash
# Manual backup script
#!/bin/bash
BACKUP_DIR="./state-backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# Pull current state
terraform state pull > "$BACKUP_DIR/state-$DATE.tfstate"

# Backup to separate S3 bucket
aws s3 cp "$BACKUP_DIR/state-$DATE.tfstate" \
  s3://my-backup-bucket/connect-instance/state-$DATE.tfstate

# Keep only last 30 days locally
find $BACKUP_DIR -name "state-*.tfstate" -mtime +30 -delete

echo "Backup completed: state-$DATE.tfstate"
```

### Recovery Procedures

```bash
# Recovery from S3 version
./scripts/recover-state.sh <version-id>

# Recovery from backup bucket
aws s3 cp s3://my-backup-bucket/connect-instance/state-latest.tfstate ./recovered.tfstate
terraform state push recovered.tfstate

# Verify recovery
terraform state list
terraform plan
```

## Monitoring and Alerts

### CloudWatch Alarms

```bash
# Monitor state file changes
aws cloudwatch put-metric-alarm \
  --alarm-name terraform-state-frequent-changes \
  --alarm-description "Alert on frequent state modifications" \
  --metric-name NumberOfObjects \
  --namespace AWS/S3 \
  --statistic Average \
  --period 3600 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=BucketName,Value=my-terraform-state-bucket
```

### State Health Dashboard

```bash
#!/bin/bash
# state-health-check.sh

echo "=== Terraform State Health Check ==="
echo "Date: $(date)"
echo ""

# Check S3 state file
echo "1. S3 State File Status:"
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --query '{LastModified:LastModified,Size:ContentLength,ETag:ETag}' \
  --output table

# Check lock status
echo "2. Lock Status:"
LOCK_COUNT=$(aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "contains(LockID, :key)" \
  --expression-attribute-values '{":key":{"S":"connect-instance"}}' \
  --query 'Count' \
  --output text)
echo "Active locks: $LOCK_COUNT"

# Check resource count
echo "3. Resource Count:"
RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l)
echo "Total resources: $RESOURCE_COUNT"

# Check drift
echo "4. Drift Status:"
terraform plan -detailed-exitcode > /dev/null 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ No drift detected"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "⚠ Drift detected - run terraform plan"
else
  echo "✗ Error checking drift"
fi

echo ""
echo "=== End Health Check ==="
```

## Best Practices

1. **Always enable S3 versioning** - Critical for disaster recovery
2. **Use encryption** - Both at rest and in transit
3. **Enable access logging** - Track who accesses state
4. **Regular backups** - Automated daily backups to separate location
5. **Test recovery** - Monthly disaster recovery drills
6. **Monitor state size** - Large states indicate design issues
7. **Use state locking** - Prevent concurrent modifications
8. **Restrict access** - Principle of least privilege
9. **Audit changes** - Regular review of state modifications
10. **Document procedures** - Clear runbooks for common issues

## Quick Reference

| Task | Command |
|------|---------|
| Check state exists | `aws s3 ls s3://bucket/key` |
| Get state metadata | `aws s3api head-object --bucket X --key Y` |
| List state versions | `aws s3api list-object-versions --bucket X --prefix Y` |
| Check lock | `aws dynamodb get-item --table-name terraform-state-lock --key '{...}'` |
| Force unlock | `terraform force-unlock <lock-id>` |
| Pull state | `terraform state pull > backup.tfstate` |
| Push state | `terraform state push backup.tfstate` |
| List resources | `terraform state list` |
| Verify integrity | `terraform state list > /dev/null && echo OK` |
| Check drift | `terraform plan -detailed-exitcode` |

---

**Related Documentation:**
- [Main README](README.md)
- [Operations Guide](OPERATIONS_GUIDE.md)
