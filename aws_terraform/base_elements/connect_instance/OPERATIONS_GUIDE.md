# Connect Instance Operations Guide

This guide provides step-by-step instructions for common operational tasks using targeted Terraform commands.

## Prerequisites

Before running any commands, ensure:

1. **S3 Backend Configured**: State is stored in S3
2. **Initialized**: Run `terraform init` 
3. **DynamoDB Lock Table**: Created for state locking
4. **Proper IAM Permissions**: For Connect, S3, and DynamoDB

## Day-to-Day Operations

### Adding a New Agent

**Scenario**: Add a new agent to the support team

```bash
# 1. Update your terraform.tfvars
cat >> terraform.tfvars <<'EOF'
users = {
  # ... existing users ...
  "jane.smith" = {
    username                = "jane.smith"
    email                   = "jane.smith@example.com"
    first_name             = "Jane"
    last_name              = "Smith"
    phone_type             = "SOFT_PHONE"
    routing_profile_name   = "SupportAgentProfile"
    security_profile_names = ["AgentAccess"]
    hierarchy_group_name   = "Support"
  }
}
EOF

# 2. Plan the change
terraform plan -target=module.connect.aws_connect_user.users

# 3. Apply only user changes
terraform apply -target=module.connect.aws_connect_user.users

# 4. Verify user was created
terraform state show 'module.connect.aws_connect_user.users["jane.smith"]'

# 5. Check state in S3
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate | jq '.LastModified'
```

### Adding a Phone Number

**Scenario**: Add a new support phone line

```bash
# 1. Update terraform.tfvars
cat >> terraform.tfvars <<'EOF'
phone_numbers = {
  # ... existing numbers ...
  "premium_support" = {
    country_code = "GB"
    type         = "DID"
    description  = "Premium support hotline"
  }
}
EOF

# 2. Plan phone number changes
terraform plan -target=module.connect.aws_connect_phone_number.phone_numbers

# 3. Apply changes
terraform apply -target=module.connect.aws_connect_phone_number.phone_numbers

# 4. Get the phone number details
terraform output phone_numbers | jq '.premium_support'

# 5. Verify state consistency
terraform state list | grep phone_number
```

### Updating Contact Flows

**Scenario**: Update the main customer service flow

```bash
# 1. Edit the contact flow JSON file
vim contact-flows/customer-service.json

# 2. Ensure terraform.tfvars references it
cat terraform.tfvars | grep -A 5 "contact_flows"

# 3. Plan contact flow changes
terraform plan -target=module.connect.aws_connect_contact_flow.contact_flows

# 4. Apply only contact flow changes
terraform apply -target=module.connect.aws_connect_contact_flow.contact_flows

# 5. Verify the update
terraform state show 'module.connect.aws_connect_contact_flow.contact_flows["customer_service"]'

# 6. Check CloudWatch logs for flow errors
aws logs tail /aws/connect/my-contact-center --follow
```

### Modifying Queue Settings

**Scenario**: Increase max contacts for support queue

```bash
# 1. Update queue configuration
# Edit terraform.tfvars to change max_contacts

# 2. Preview changes
terraform plan -target=module.connect.aws_connect_queue.queues

# 3. Apply queue changes only
terraform apply -target=module.connect.aws_connect_queue.queues

# 4. Verify the change
terraform state show 'module.connect.aws_connect_queue.queues["support"]'
```

### Adding Security Profile

**Scenario**: Create new team lead security profile

```bash
# 1. Add to terraform.tfvars
cat >> terraform.tfvars <<'EOF'
security_profiles = [
  # ... existing profiles ...
  {
    name        = "TeamLeadProfile"
    description = "Team lead permissions"
    permissions = [
      "BasicAgentAccess",
      "AccessMetrics",
      "ManagerListenIn",
      "AccessQualityManagement"
    ]
  }
]
EOF

# 2. Plan security profile changes
terraform plan -target=module.connect.aws_connect_security_profile.security_profiles

# 3. Apply
terraform apply -target=module.connect.aws_connect_security_profile.security_profiles

# 4. Verify
terraform state list | grep security_profile
```

### Batch User Updates

**Scenario**: Update routing profile for multiple agents

```bash
# 1. Update all affected users in terraform.tfvars
# Change routing_profile_name for multiple users

# 2. Plan changes (will show all user updates)
terraform plan -target=module.connect.aws_connect_user.users

# 3. Review carefully, then apply
terraform apply -target=module.connect.aws_connect_user.users

# 4. Verify multiple users updated
terraform state list | grep aws_connect_user.users
```

## State Management Operations

### Inspecting Current State

```bash
# List all resources
terraform state list

# Filter for specific types
terraform state list | grep user
terraform state list | grep phone
terraform state list | grep queue

# Show detailed resource info
terraform state show 'module.connect.aws_connect_instance.this'

# Export state to JSON for analysis
terraform show -json > current-state.json
jq '.values.root_module.child_modules[] | select(.address=="module.connect")' current-state.json
```

### State Backup and Recovery

```bash
# Manual backup before major changes
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# List S3 versions (if versioning enabled)
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[*].[VersionId,LastModified]' \
  --output table

# Download specific version
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id <version-id> \
  ./recovered-state.tfstate

# Restore state (CAUTION!)
# terraform state push ./recovered-state.tfstate
```

### State Drift Detection

```bash
# Check for drift
terraform plan -detailed-exitcode
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "No drift detected"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "Drift detected - review plan output"
  terraform plan -no-color > drift-report-$(date +%Y%m%d).txt
else
  echo "Error occurred"
fi

# Refresh state to sync with reality
terraform refresh

# Or refresh specific resource
terraform refresh -target=module.connect.aws_connect_user.users
```

### Verifying S3 State Consistency

```bash
# Check state file exists
aws s3 ls s3://my-terraform-state-bucket/connect-instance/terraform.tfstate

# Get state file metadata
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate

# Verify state lock table
aws dynamodb describe-table \
  --table-name terraform-state-lock \
  --query 'Table.TableStatus'

# Check for active locks
aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "contains(LockID, :prefix)" \
  --expression-attribute-values '{":prefix":{"S":"my-terraform-state-bucket/connect-instance"}}' \
  --query 'Items[*].[LockID.S,Info.S]' \
  --output table
```

## Troubleshooting Operations

### State Lock Issues

```bash
# Check who has the lock
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}' \
  --query 'Item.Info.S' \
  --output text | jq .

# Get lock ID
LOCK_ID=$(aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}' \
  --query 'Item.LockID.S' \
  --output text)

# Force unlock (use cautiously)
terraform force-unlock $LOCK_ID
```

### Resource Import

```bash
# Import existing Connect instance
INSTANCE_ARN="arn:aws:connect:eu-west-2:123456789012:instance/abcd1234-5678-90ef-ghij-klmnopqrstuv"
terraform import module.connect.aws_connect_instance.this $INSTANCE_ARN

# Import phone number
INSTANCE_ID="abcd1234-5678-90ef-ghij-klmnopqrstuv"
PHONE_ID="phone1234-5678-90ef-ghij-klmnopqrstuv"
terraform import 'module.connect.aws_connect_phone_number.phone_numbers["main"]' $INSTANCE_ID/$PHONE_ID

# Import user
USER_ID="user1234-5678-90ef-ghij-klmnopqrstuv"
terraform import 'module.connect.aws_connect_user.users["john.doe"]' $INSTANCE_ID/$USER_ID

# Verify import
terraform state show 'module.connect.aws_connect_user.users["john.doe"]'
```

### Removing Resources

```bash
# Remove from Terraform (keeps in AWS)
terraform state rm 'module.connect.aws_connect_user.users["old.user"]'

# Destroy specific resource
terraform destroy -target='module.connect.aws_connect_user.users["old.user"]'

# Verify removal
terraform state list | grep old.user
```

## Production Workflows

### Safe Production Deployment

```bash
# 1. Create and save plan
terraform plan -out=production-$(date +%Y%m%d).tfplan

# 2. Review plan thoroughly
terraform show production-$(date +%Y%m%d).tfplan | less

# 3. Get approval (manual step)
echo "Waiting for approval..."

# 4. Apply saved plan
terraform apply production-$(date +%Y%m%d).tfplan

# 5. Verify state in S3
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate

# 6. Create backup tag
aws s3api put-object-tagging \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --tagging "TagSet=[{Key=LastDeployment,Value=$(date +%Y%m%d)}]"
```

### Emergency Rollback

```bash
# 1. List recent state versions
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --max-items 10

# 2. Download previous version
PREVIOUS_VERSION_ID="<version-id-from-step-1>"
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id $PREVIOUS_VERSION_ID \
  ./rollback-state.tfstate

# 3. Backup current state first
terraform state pull > current-state-backup.tfstate

# 4. Push previous state
terraform state push ./rollback-state.tfstate

# 5. Verify
terraform plan
```

### Multi-Environment Management

```bash
# Development environment
terraform workspace select dev
terraform apply -target=module.connect.aws_connect_user.users

# Staging environment
terraform workspace select staging
terraform apply -target=module.connect.aws_connect_user.users

# Production environment (with plan file)
terraform workspace select prod
terraform plan -out=prod.tfplan
terraform apply prod.tfplan

# List workspaces
terraform workspace list
```

## Performance Optimization

### Parallel Operations

```bash
# Terraform automatically parallelizes, but you can control it
terraform apply -parallelism=10 -target=module.connect.aws_connect_user.users

# For large deployments, reduce parallelism to avoid API throttling
terraform apply -parallelism=5
```

### Caching and Refresh

```bash
# Skip refresh for faster plans (use carefully)
terraform plan -refresh=false

# Refresh only specific resources
terraform refresh -target=module.connect.aws_connect_queue.queues
```

## Validation and Testing

### Pre-deployment Validation

```bash
# Validate configuration syntax
terraform validate

# Format check
terraform fmt -check -recursive

# Security scanning (requires tfsec)
tfsec .

# Cost estimation (requires infracost)
infracost breakdown --path .

# Generate documentation (requires terraform-docs)
terraform-docs markdown table . > TERRAFORM.md
```

### Post-deployment Verification

```bash
# Verify outputs
terraform output

# Check specific output
terraform output -json phone_numbers | jq .

# Test Connect instance
aws connect describe-instance --instance-id <instance-id>

# List users
aws connect list-users --instance-id <instance-id>

# Test phone number
aws connect describe-phone-number \
  --phone-number-id <phone-id> \
  --instance-id <instance-id>
```

## Monitoring and Auditing

### State Audit

```bash
# Generate state report
terraform state list > state-inventory-$(date +%Y%m%d).txt

# Count resources by type
terraform state list | awk -F. '{print $3}' | sort | uniq -c

# Check for orphaned resources
terraform plan -detailed-exitcode
```

### Change Tracking

```bash
# View state history
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate \
  --query 'Versions[*].[LastModified,Size,VersionId]' \
  --output table

# Compare state versions
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id <version-1> v1.tfstate

aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id <version-2> v2.tfstate

diff v1.tfstate v2.tfstate
```

## Best Practices Summary

1. **Always use S3 backend** with versioning enabled
2. **Use DynamoDB** for state locking
3. **Create plan files** for production deployments
4. **Use `-target`** for surgical updates
5. **Backup state** before major changes
6. **Verify in S3** after critical operations
7. **Test in non-prod** environments first
8. **Document changes** in commit messages
9. **Use workspaces** for multi-environment setups
10. **Monitor drift** regularly

## Quick Reference

| Operation | Command |
|-----------|---------|
| Add user | `terraform apply -target='module.connect.aws_connect_user.users["name"]'` |
| Add phone | `terraform apply -target=module.connect.aws_connect_phone_number.phone_numbers` |
| Update flows | `terraform apply -target=module.connect.aws_connect_contact_flow.contact_flows` |
| Update queues | `terraform apply -target=module.connect.aws_connect_queue.queues` |
| List resources | `terraform state list` |
| Show resource | `terraform state show 'module.connect.resource.name'` |
| Check drift | `terraform plan -detailed-exitcode` |
| Backup state | `terraform state pull > backup.tfstate` |
| Check S3 state | `aws s3 ls s3://bucket/connect-instance/` |
| Verify lock | `aws dynamodb scan --table-name terraform-state-lock` |

---

**Need Help?** See the main [README.md](README.md) for full documentation.
