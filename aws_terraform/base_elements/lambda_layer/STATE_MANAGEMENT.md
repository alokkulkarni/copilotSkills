# Terraform State Management with S3

This Lambda Layer module uses the same state management principles as all Terraform modules. For comprehensive S3 state management documentation, see the [Connect Instance State Management Guide](../connect_instance/STATE_MANAGEMENT.md).

## Quick Reference for Lambda Layers

### Initialize Backend

```bash
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "lambda-layer/my-layer/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Verify State

```bash
# Check state file
aws s3 ls s3://my-terraform-state-bucket/lambda-layer/my-layer/terraform.tfstate

# List resources
terraform state list

# Simple module - typically just one resource
terraform state show 'module.layer.aws_lambda_layer_version.this'
```

## Complete Documentation

For detailed information on S3 state management, see the **[Complete State Management Guide](../connect_instance/STATE_MANAGEMENT.md)**.
