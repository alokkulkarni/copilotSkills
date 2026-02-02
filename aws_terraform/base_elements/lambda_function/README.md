# AWS Lambda Function Terraform Module

This module creates an AWS Lambda function with comprehensive configuration options including IAM role management, VPC integration, Lambda layers support, environment variables, CloudWatch logging, X-Ray tracing, and Function URLs. Designed for production use with best practices built-in.

## Quick Start Command Reference

### Most Common Operations

```bash
# Initialize with S3 backend
terraform init

# Plan/Apply specific components
terraform apply -target=module.lambda.aws_lambda_function.this              # Lambda function only
terraform apply -target=module.lambda.aws_iam_role.lambda_role              # IAM role only
terraform apply -target=module.lambda.aws_lambda_function_url.this          # Function URL only
terraform apply -target=module.lambda.aws_lambda_alias.this                 # Alias only

# Verify state
terraform state list                                                        # List all resources
terraform state show 'module.lambda.aws_lambda_function.this'               # Show function details

# Check S3 state
aws s3 ls s3://my-terraform-state-bucket/lambda/                            # List state files
```

**📘 For detailed command reference, see [Terraform Commands and State Management](#terraform-commands-and-state-management) section below.**  
**📕 For step-by-step operational procedures, see [OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md).**  
**📗 For complete S3 state management guide, see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md).**

## Table of Contents

- [Module Structure](#module-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- **[📘 Terraform Commands and State Management](#terraform-commands-and-state-management)** ⭐
- **[📋 Module-Level vs Component-Level Operations](#module-level-vs-component-level-operations)** ⭐
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

### 📚 Additional Documentation

- **[OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md)** - Step-by-step procedures for common operational tasks
- **[STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)** - Complete guide for S3 state backend setup and management

## Module Structure

The module is organized into separate, focused files for better maintainability:

```
lambda_function/
├── main.tf                    # Core Lambda function resource
├── iam.tf                     # IAM roles and policies
├── logging.tf                 # CloudWatch log groups
├── function_url.tf            # Lambda function URLs and permissions
├── alias.tf                   # Lambda aliases and routing
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider version constraints
└── README.md                  # This file
```

### Benefits of Modular Structure

- **Focused Changes**: Update IAM policies without touching function configuration
- **Clear Separation**: Each file has a single responsibility
- **Easy Navigation**: Quickly locate resources by category
- **Independent Testing**: Test specific components in isolation

## Features

- ✅ Automatic IAM role creation with customizable policies
- ✅ Support for Lambda layers (up to 5 layers)
- ✅ VPC configuration for secure networking
- ✅ CloudWatch Logs integration with configurable retention
- ✅ X-Ray tracing support
- ✅ Dead Letter Queue (DLQ) configuration
- ✅ Function URL support with CORS
- ✅ Lambda aliases with weighted routing
- ✅ EFS file system integration
- ✅ Container image support
- ✅ Code signing support
- ✅ Snap Start for Java functions
- ✅ Both x86_64 and ARM64 architecture support
- ✅ Environment variable management (sensitive)
- ✅ Configurable memory, timeout, and concurrency
- ✅ Local file or S3-based deployment

## Usage

### Basic Lambda Function

```hcl
module "hello_world_lambda" {
  source = "./base_elements/lambda_function"

  function_name = "hello-world-function"
  description   = "Simple Hello World Lambda function"
  
  handler = "index.handler"
  runtime = "python3.11"
  
  filename         = "${path.module}/lambda/hello-world.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/hello-world.zip")
  
  timeout     = 30
  memory_size = 256
  
  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}
```

### Lambda Function with Layers

```hcl
# Create the layer first
module "python_utils_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "python-utils-layer"
  filename            = "${path.module}/layers/python-utils.zip"
  compatible_runtimes = ["python3.11"]
}

# Create function that uses the layer
module "lambda_with_layers" {
  source = "./base_elements/lambda_function"

  function_name = "data-processor"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Attach the layer
  layers = [
    module.python_utils_layer.layer_arn
  ]
  
  environment_variables = {
    LAYER_VERSION = module.python_utils_layer.layer_version
  }
}
```

### Lambda Function in VPC

```hcl
module "vpc_lambda" {
  source = "./base_elements/lambda_function"

  function_name = "vpc-lambda-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # VPC configuration
  vpc_config = {
    subnet_ids = [
      "subnet-12345678",
      "subnet-87654321"
    ]
    security_group_ids = [
      "sg-12345678"
    ]
  }
  
  # VPC functions need more time to initialize
  timeout     = 60
  memory_size = 512
}
```

### Lambda Function with Custom IAM Policies

```hcl
# Create custom IAM policy
resource "aws_iam_policy" "s3_access" {
  name        = "lambda-s3-access"
  description = "Allow Lambda to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })
}

module "lambda_with_s3_access" {
  source = "./base_elements/lambda_function"

  function_name = "s3-processor"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Attach custom policy
  attach_policy_arns = [
    aws_iam_policy.s3_access.arn
  ]
  
  environment_variables = {
    BUCKET_NAME = "my-bucket"
  }
}
```

### Lambda Function with X-Ray Tracing

```hcl
module "traced_lambda" {
  source = "./base_elements/lambda_function"

  function_name = "traced-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Enable X-Ray tracing
  tracing_mode = "Active"
  
  # Attach X-Ray write policy
  attach_policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]
}
```

### Lambda Function with Dead Letter Queue

```hcl
# Create SQS queue for DLQ
resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "lambda-dlq"
  message_retention_seconds = 1209600  # 14 days
}

module "lambda_with_dlq" {
  source = "./base_elements/lambda_function"

  function_name = "async-processor"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Configure DLQ
  dead_letter_target_arn = aws_sqs_queue.lambda_dlq.arn
  
  # Add SQS send message permission
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.lambda_dlq.arn
      }
    ]
  })
}
```

### Lambda Function with Function URL

```hcl
module "lambda_with_url" {
  source = "./base_elements/lambda_function"

  function_name = "web-handler"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Enable Function URL
  create_function_url    = true
  function_url_auth_type = "NONE"  # Public access
  
  # Configure CORS
  function_url_cors_config = {
    allow_origins = ["https://example.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

output "function_url" {
  value = module.lambda_with_url.function_url
}
```

### Lambda Function with Existing IAM Role

```hcl
# Use existing IAM role
resource "aws_iam_role" "existing_lambda_role" {
  name = "existing-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

module "lambda_existing_role" {
  source = "./base_elements/lambda_function"

  function_name = "existing-role-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Use existing role
  create_role     = false
  lambda_role_arn = aws_iam_role.existing_lambda_role.arn
}
```

### Lambda Function with S3 Deployment

```hcl
module "lambda_from_s3" {
  source = "./base_elements/lambda_function"

  function_name = "s3-deployed-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  
  # Deploy from S3
  s3_bucket        = "my-lambda-deployments"
  s3_key           = "functions/my-function-v1.0.0.zip"
  s3_object_version = "abc123xyz"
  
  memory_size = 512
  timeout     = 60
}
```

### Lambda Function with ARM64 Architecture

```hcl
module "arm_lambda" {
  source = "./base_elements/lambda_function"

  function_name = "arm-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Use ARM64 (Graviton2) for better cost/performance
  architectures = ["arm64"]
  
  memory_size = 1024
  timeout     = 30
}
```

### Lambda Function with Alias and Traffic Shifting

```hcl
module "lambda_with_alias" {
  source = "./base_elements/lambda_function"

  function_name = "production-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda/function.zip"
  
  # Publish new version
  publish = true
  
  # Create alias
  create_alias          = true
  alias_name            = "live"
  alias_function_version = "2"
  
  # Traffic shifting (90% to v2, 10% to v1)
  alias_routing_config = {
    additional_version_weights = {
      "1" = 0.1
    }
  }
}
```

### Complete Production Example

```hcl
# Lambda layer with dependencies
module "production_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "production-dependencies"
  description         = "Production dependencies for data processing"
  filename            = "${path.module}/layers/dependencies.zip"
  source_code_hash    = filebase64sha256("${path.module}/layers/dependencies.zip")
  compatible_runtimes = ["python3.11"]
  license_info        = "MIT"
}

# Custom IAM policies
resource "aws_iam_policy" "lambda_policies" {
  name = "production-lambda-policies"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::production-data/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/production-table"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:prod/*"
      }
    ]
  })
}

# DLQ for failed invocations
resource "aws_sqs_queue" "lambda_dlq" {
  name                       = "production-lambda-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300

  kms_master_key_id = aws_kms_key.lambda_kms.id
}

# KMS key for encryption
resource "aws_kms_key" "lambda_kms" {
  description             = "KMS key for Lambda encryption"
  deletion_window_in_days = 10
}

# Production Lambda function
module "production_lambda" {
  source = "./base_elements/lambda_function"

  function_name = "production-data-processor"
  description   = "Production data processing Lambda function"
  
  # Code configuration
  handler          = "app.handler"
  runtime          = "python3.11"
  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")
  
  # Performance configuration
  memory_size                    = 2048
  timeout                        = 300
  reserved_concurrent_executions = 10
  architectures                  = ["arm64"]
  
  # Attach layer
  layers = [module.production_layer.layer_arn]
  
  # Environment variables
  environment_variables = {
    ENVIRONMENT     = "production"
    TABLE_NAME      = "production-table"
    BUCKET_NAME     = "production-data"
    LOG_LEVEL       = "INFO"
  }
  
  # VPC configuration
  vpc_config = {
    subnet_ids = [
      "subnet-prod-1",
      "subnet-prod-2"
    ]
    security_group_ids = [
      "sg-prod-lambda"
    ]
  }
  
  # IAM policies
  attach_policy_arns = [
    aws_iam_policy.lambda_policies.arn,
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]
  
  # Monitoring and logging
  tracing_mode         = "Active"
  log_retention_days   = 30
  log_kms_key_id       = aws_kms_key.lambda_kms.arn
  
  # Error handling
  dead_letter_target_arn = aws_sqs_queue.lambda_dlq.arn
  
  # Versioning and aliasing
  publish                = true
  create_alias           = true
  alias_name             = "production"
  alias_function_version = "$LATEST"
  
  # Tags
  tags = {
    Environment = "production"
    Project     = "data-processing"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Unique name for the Lambda function | `string` | n/a | yes |
| handler | Function entrypoint in your code | `string` | n/a | yes |
| runtime | Lambda runtime identifier | `string` | n/a | yes |
| description | Description of the Lambda function | `string` | `""` | no |
| filename | Path to the local zip file containing the function code | `string` | `null` | no* |
| s3_bucket | S3 bucket containing the function code | `string` | `null` | no* |
| s3_key | S3 key of the function code zip file | `string` | `null` | no* |
| s3_object_version | S3 object version of the function code | `string` | `null` | no |
| source_code_hash | Base64-encoded SHA256 hash of the function code | `string` | `null` | no |
| timeout | Amount of time Lambda function has to run in seconds (1-900) | `number` | `3` | no |
| memory_size | Amount of memory in MB (128-10240) | `number` | `128` | no |
| reserved_concurrent_executions | Amount of reserved concurrent executions | `number` | `-1` | no |
| publish | Whether to publish creation/change as new version | `bool` | `false` | no |
| architectures | Instruction set architecture (x86_64 or arm64) | `list(string)` | `["x86_64"]` | no |
| layers | List of Lambda layer ARNs (max 5) | `list(string)` | `[]` | no |
| environment_variables | Map of environment variables | `map(string)` | `null` | no |
| vpc_config | VPC configuration object | `object` | `null` | no |
| create_role | Whether to create a new IAM role | `bool` | `true` | no |
| lambda_role_arn | ARN of existing IAM role | `string` | `null` | no* |
| attach_cloudwatch_logs_policy | Whether to attach CloudWatch Logs policy | `bool` | `true` | no |
| attach_policy_arns | List of IAM policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policy | JSON-encoded IAM inline policy | `string` | `null` | no |
| create_log_group | Whether to create CloudWatch Log Group | `bool` | `true` | no |
| log_retention_days | Number of days to retain logs | `number` | `14` | no |
| log_kms_key_id | KMS key ID for log encryption | `string` | `null` | no |
| dead_letter_target_arn | ARN of SNS topic or SQS queue for DLQ | `string` | `null` | no |
| tracing_mode | X-Ray tracing mode (Active or PassThrough) | `string` | `null` | no |
| ephemeral_storage_size | Size of /tmp directory in MB (512-10240) | `number` | `null` | no |
| file_system_config | EFS file system configuration | `object` | `null` | no |
| image_config | Container image configuration | `object` | `null` | no |
| code_signing_config_arn | ARN of code signing configuration | `string` | `null` | no |
| snap_start_apply_on | Snap start setting (Java only) | `string` | `null` | no |
| create_function_url | Whether to create a Function URL | `bool` | `false` | no |
| function_url_auth_type | Authorization type for Function URL | `string` | `"AWS_IAM"` | no |
| function_url_cors_config | CORS configuration for Function URL | `object` | `null` | no |
| create_alias | Whether to create an alias | `bool` | `false` | no |
| alias_name | Name for the Lambda function alias | `string` | `"live"` | no |
| alias_description | Description for the alias | `string` | `""` | no |
| alias_function_version | Lambda function version for alias | `string` | `"$LATEST"` | no |
| alias_routing_config | Routing configuration for weighted alias routing | `object` | `null` | no |
| tags | Map of tags to assign to resources | `map(string)` | `{}` | no |

*Note: Either `filename` OR (`s3_bucket` + `s3_key`) must be provided. If `create_role` is false, `lambda_role_arn` is required.

## Outputs

| Name | Description |
|------|-------------|
| function_arn | ARN of the Lambda function |
| function_name | Name of the Lambda function |
| function_qualified_arn | Qualified ARN (includes version) |
| function_version | Latest published version |
| function_last_modified | Date last modified |
| function_invoke_arn | ARN for invoking from API Gateway |
| function_source_code_size | Size of deployment package in bytes |
| function_code_sha256 | SHA256 hash of function package |
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| log_group_name | Name of CloudWatch Log Group |
| log_group_arn | ARN of CloudWatch Log Group |
| function_url | URL endpoint (if Function URL is enabled) |
| function_url_id | ID of Function URL configuration |
| alias_arn | ARN of the function alias |
| alias_name | Name of the function alias |
| alias_invoke_arn | ARN for invoking the alias |

## Best Practices

### 1. Memory and Performance
- Start with 128 MB and increase based on CloudWatch metrics
- More memory = more CPU = faster execution (and higher cost)
- Use AWS Lambda Power Tuning tool to find optimal memory

### 2. Timeout Configuration
- Set realistic timeouts based on actual execution time
- Add buffer time for cold starts (especially for VPC functions)
- Default timeout (3s) is often too short for real applications

### 3. Environment Variables
- Use for configuration, not secrets
- Store secrets in AWS Secrets Manager or Parameter Store
- Mark `environment_variables` as sensitive in your tfvars

### 4. IAM Permissions
- Follow least privilege principle
- Use resource-level permissions when possible
- Avoid wildcard (*) permissions in production

### 5. VPC Configuration
- Only use VPC if you need to access VPC resources
- VPC adds cold start latency
- Ensure subnets have NAT Gateway for internet access
- Use VPC endpoints to reduce data transfer costs

### 6. Logging
- Use structured logging (JSON) for easier parsing
- Set appropriate log retention periods
- Consider log costs for high-volume functions

### 7. Layers
- Use layers for shared dependencies
- Keep layers small and focused
- Version your layers
- Maximum 5 layers per function

### 8. Error Handling
- Configure DLQ for asynchronous invocations
- Implement retry logic in your code
- Use X-Ray for distributed tracing

### 9. Versioning and Aliases
- Use versioning for production deployments
- Use aliases for traffic shifting and rollbacks
- Never point production traffic to $LATEST

### 10. Cost Optimization
- Consider ARM64 architecture (20% cheaper)
- Right-size memory allocation
- Use reserved concurrency carefully (you pay for it)
- Clean up old versions

## Terraform Commands and State Management

### Backend Configuration for S3 State

Configure S3 backend in your root module:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "lambda/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Targeted Terraform Operations

#### Update Lambda Function Only

```bash
# Update function configuration
terraform apply -target=module.lambda.aws_lambda_function.this

# Update environment variables
terraform apply -target=module.lambda.aws_lambda_function.this \
  -var 'environment_variables={"KEY":"value"}'
```

#### Update IAM Role Only

```bash
terraform apply -target=module.lambda.aws_iam_role.lambda_role
terraform apply -target=module.lambda.aws_iam_role_policy.lambda_inline_policy
```

#### Update Function URL Only

```bash
terraform apply -target=module.lambda.aws_lambda_function_url.this
terraform apply -target=module.lambda.aws_lambda_permission.function_url
```

#### Update CloudWatch Logs Only

```bash
terraform apply -target=module.lambda.aws_cloudwatch_log_group.lambda_log_group
```

#### Update Alias Only

```bash
terraform apply -target=module.lambda.aws_lambda_alias.this
```

### State Verification

```bash
# List all resources
terraform state list

# Show function details
terraform state show 'module.lambda.aws_lambda_function.this'

# Check S3 state
aws s3 ls s3://my-terraform-state-bucket/lambda/terraform.tfstate
```

## Module-Level vs Component-Level Operations

### Component Mapping

| Component | File | Resource Type | Target Flag Example |
|-----------|------|---------------|---------------------|
| **Lambda Function** | main.tf | `aws_lambda_function` | `-target=module.lambda.aws_lambda_function.this` |
| **IAM Role** | iam.tf | `aws_iam_role` | `-target=module.lambda.aws_iam_role.lambda_role` |
| **IAM Policies** | iam.tf | `aws_iam_role_policy` | `-target=module.lambda.aws_iam_role_policy.lambda_inline_policy` |
| **CloudWatch Logs** | logging.tf | `aws_cloudwatch_log_group` | `-target=module.lambda.aws_cloudwatch_log_group.lambda_log_group` |
| **Function URL** | function_url.tf | `aws_lambda_function_url` | `-target=module.lambda.aws_lambda_function_url.this` |
| **Alias** | alias.tf | `aws_lambda_alias` | `-target=module.lambda.aws_lambda_alias.this` |

### Example: Update Function Code Only

```bash
# 1. Update function zip file
zip -r function.zip index.js

# 2. Update terraform.tfvars
source_code_hash = filebase64sha256("function.zip")

# 3. Apply only function changes
terraform apply -target=module.lambda.aws_lambda_function.this

# 4. Verify
terraform state show 'module.lambda.aws_lambda_function.this' | grep source_code_hash
```

## Lambda Function Size Limits

- **Deployment package size**: 50 MB (zipped, direct upload)
- **Deployment package size**: 250 MB (unzipped, including layers)
- **S3 deployment package**: 50 MB (zipped)
- **/tmp storage**: 512 MB (default), up to 10 GB (configurable)
- **Environment variables**: 4 KB total
- **Memory**: 128 MB to 10,240 MB (10 GB)
- **Timeout**: 1 second to 15 minutes (900 seconds)

## Supported Runtimes

- **Python**: 3.8, 3.9, 3.10, 3.11, 3.12
- **Node.js**: 16.x, 18.x, 20.x
- **Java**: 8, 8.al2, 11, 17, 21
- **Ruby**: 2.7, 3.2
- **Go**: 1.x (provided.al2, provided.al2023)
- **.NET**: 6, 8
- **Custom Runtime**: provided, provided.al2, provided.al2023

Check [AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) for the latest supported versions.

## Troubleshooting

### Function Timeout
- Increase timeout value
- Optimize code performance
- Check for network latency (VPC, external APIs)

### Out of Memory
- Increase memory_size
- Check for memory leaks
- Review CloudWatch metrics

### Permission Denied
- Verify IAM role permissions
- Check resource policies (S3 bucket policy, etc.)
- Review CloudWatch Logs for specific errors

### Cold Start Issues
- Consider provisioned concurrency (not in this module)
- Optimize package size
- Use ARM64 for faster cold starts
- Remove VPC if not needed

## License

This module is licensed under the MIT License.

## Authors

Created and maintained by Alok Kulkarni.

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform AWS Lambda Function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- [Lambda Operator Guide](https://docs.aws.amazon.com/lambda/latest/operatorguide/intro.html)
