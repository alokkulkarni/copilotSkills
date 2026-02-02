# Terraform State Management with S3

This Lambda Function module uses the same state management principles as all Terraform modules. For comprehensive S3 state management documentation, see the [Connect Instance State Management Guide](../connect_instance/STATE_MANAGEMENT.md).

## Quick Reference for Lambda Functions

### Initialize Backend

```bash
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "lambda/my-function/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Verify State

```bash
# Check state file
aws s3 ls s3://my-terraform-state-bucket/lambda/my-function/terraform.tfstate

# List resources
terraform state list

# Check for drift
terraform plan -detailed-exitcode
```

### Backup State

```bash
# Pull current state
terraform state pull > backup-$(date +%Y%m%d).tfstate

# List versions in S3
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix lambda/my-function/terraform.tfstate
```

## Complete Documentation

For detailed information on:
- S3 bucket setup with versioning
- DynamoDB lock table configuration
- State recovery procedures
- Disaster recovery
- Security best practices
- Monitoring and alerts

See the **[Complete State Management Guide](../connect_instance/STATE_MANAGEMENT.md)**.
