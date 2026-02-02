# Lambda Function Operations Guide

Step-by-step procedures for common operational tasks with the Lambda function Terraform module.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- S3 backend configured for state
- DynamoDB table for state locking

## Common Operations

### Updating Function Code

```bash
# 1. Update your function code and create new zip
cd lambda-src
zip -r ../function.zip .

# 2. Update source code hash in terraform.tfvars
source_code_hash = filebase64sha256("function.zip")

# 3. Plan changes
terraform plan -target=module.lambda.aws_lambda_function.this

# 4. Apply code update
terraform apply -target=module.lambda.aws_lambda_function.this

# 5. Verify deployment
aws lambda get-function --function-name my-function | jq '.Configuration.CodeSha256'
```

### Updating Environment Variables

```bash
# 1. Edit terraform.tfvars
environment_variables = {
  API_KEY = "new-value"
  DEBUG   = "true"
}

# 2. Apply changes
terraform apply -target=module.lambda.aws_lambda_function.this

# 3. Verify
aws lambda get-function-configuration \
  --function-name my-function | jq '.Environment.Variables'
```

### Updating IAM Permissions

```bash
# 1. Update inline_policy in terraform.tfvars or add to attach_policy_arns

# 2. Apply IAM changes
terraform apply \
  -target=module.lambda.aws_iam_role.lambda_role \
  -target=module.lambda.aws_iam_role_policy.lambda_inline_policy

# 3. Verify
aws iam get-role --role-name my-function-role
```

### Adding Lambda Layers

```bash
# 1. Create the layer module first
# 2. Add layer ARN to function configuration

layers = [
  module.my_layer.layer_arn
]

# 3. Apply changes
terraform apply -target=module.lambda.aws_lambda_function.this

# 4. Verify
aws lambda get-function --function-name my-function | jq '.Configuration.Layers'
```

### Creating Function URL

```bash
# 1. Enable function URL in terraform.tfvars
create_function_url = true
function_url_auth_type = "NONE"  # or "AWS_IAM"

# 2. Apply
terraform apply -target=module.lambda.aws_lambda_function_url.this

# 3. Get URL
terraform output function_url
```

### Updating Log Retention

```bash
# 1. Update log_retention_days
log_retention_days = 30

# 2. Apply
terraform apply -target=module.lambda.aws_cloudwatch_log_group.lambda_log_group

# 3. Verify
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/
```

## State Management

### Check State

```bash
# List Lambda resources
terraform state list | grep lambda

# Show function details
terraform state show 'module.lambda.aws_lambda_function.this'

# Verify S3 state
aws s3 ls s3://my-terraform-state-bucket/lambda/
```

### Import Existing Function

```bash
# Import function
terraform import module.lambda.aws_lambda_function.this my-existing-function

# Import IAM role
terraform import module.lambda.aws_iam_role.lambda_role[0] my-existing-function-role

# Import log group
terraform import module.lambda.aws_cloudwatch_log_group.lambda_log_group[0] /aws/lambda/my-existing-function
```

## Troubleshooting

### Function Not Updating

```bash
# Force replacement
terraform taint module.lambda.aws_lambda_function.this
terraform apply
```

### Permission Errors

```bash
# Check IAM role
aws iam get-role --role-name my-function-role

# Check function configuration
aws lambda get-function-configuration --function-name my-function

# Check CloudWatch logs
aws logs tail /aws/lambda/my-function --follow
```

## Best Practices

1. **Always use source_code_hash** to track code changes
2. **Test locally** before deploying
3. **Use versions and aliases** for production
4. **Monitor CloudWatch metrics** for performance
5. **Keep deployment packages small** (<50MB)
6. **Use layers for dependencies**
7. **Set appropriate timeouts and memory**
8. **Enable X-Ray** for debugging
9. **Use environment variables** for configuration
10. **Review IAM permissions** regularly

---

For comprehensive state management, see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md).
