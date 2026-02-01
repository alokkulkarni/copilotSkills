# AWS Terraform Base Elements

Production-ready Terraform modules for AWS infrastructure deployment.

## Overview

This directory contains reusable, modular Terraform configurations for deploying AWS resources following infrastructure-as-code best practices. Each module is designed to be composable, well-documented, and production-ready.

## Available Modules

### Lambda Function (`lambda_function/`)

Comprehensive AWS Lambda function module with full feature support:

- ✅ Automatic IAM role creation with customizable policies
- ✅ Lambda layers support (up to 5 layers)
- ✅ VPC configuration
- ✅ CloudWatch Logs with configurable retention
- ✅ X-Ray tracing
- ✅ Dead Letter Queue configuration
- ✅ Function URL support with CORS
- ✅ Lambda aliases with weighted routing
- ✅ EFS file system integration
- ✅ Container image support
- ✅ Code signing support
- ✅ Snap Start for Java functions
- ✅ ARM64 and x86_64 architecture support

[View Lambda Function Documentation →](lambda_function/README.md)

### Lambda Layer (`lambda_layer/`)

AWS Lambda Layer module for sharing code and dependencies:

- ✅ Local file or S3-based deployment
- ✅ Multiple runtime compatibility
- ✅ Automatic versioning
- ✅ Cross-account layer sharing permissions
- ✅ Source code hash tracking for change detection
- ✅ License information support

[View Lambda Layer Documentation →](lambda_layer/README.md)

## Quick Start

### Basic Lambda Function with Layer

```hcl
# Create a Lambda layer
module "dependencies_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "my-dependencies"
  filename            = "./layers/dependencies.zip"
  compatible_runtimes = ["python3.11"]
}

# Create a Lambda function using the layer
module "my_function" {
  source = "./base_elements/lambda_function"

  function_name = "my-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "./function.zip"
  
  # Attach the layer
  layers = [module.dependencies_layer.layer_arn]
  
  environment_variables = {
    ENVIRONMENT = "production"
  }
}
```

## Examples

Complete working examples are available in the `examples/` directory:

### Lambda with Layer Example

Demonstrates deploying a Lambda function with a Lambda layer containing Python dependencies.

**Location**: `examples/lambda-with-layer/`

**Features**:
- Python Lambda function
- Lambda layer with common dependencies (requests, boto3)
- Function URL for HTTP access
- CloudWatch Logs integration
- X-Ray tracing

[View Example →](examples/lambda-with-layer/README.md)

## Directory Structure

```
aws_terraform/base_elements/
├── README.md                          # This file
├── lambda_function/                   # Lambda function module
│   ├── main.tf                       # Function resources
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── versions.tf                   # Provider versions
│   └── README.md                     # Module documentation
├── lambda_layer/                      # Lambda layer module
│   ├── main.tf                       # Layer resources
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── versions.tf                   # Provider versions
│   └── README.md                     # Module documentation
└── examples/                          # Working examples
    └── lambda-with-layer/            # Lambda + Layer example
        ├── README.md
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── build-layer.sh
        ├── build-function.sh
        ├── layer/
        │   └── requirements.txt
        └── function/
            ├── app.py
            └── api.py
```

## Module Design Principles

All modules in this directory follow these principles:

1. **Modularity**: Each module has a single, well-defined purpose
2. **Parameterization**: No hardcoded values; everything is configurable
3. **Sensible Defaults**: Provide reasonable defaults for non-critical settings
4. **Documentation**: Comprehensive README with examples and usage
5. **Best Practices**: Follow AWS and Terraform best practices
6. **Production-Ready**: Tested and suitable for production use
7. **Version Pinning**: Explicit provider version requirements

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5.0 |
| AWS Provider | >= 5.0 |

## Getting Started

### 1. Install Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- Appropriate AWS IAM permissions

### 2. Choose a Module

Select the module you need:
- Lambda function deployment → `lambda_function/`
- Lambda layer deployment → `lambda_layer/`

### 3. Review Documentation

Read the module's README.md for:
- Features and capabilities
- Input variables
- Output values
- Usage examples
- Best practices

### 4. Use the Module

Reference the module in your Terraform configuration:

```hcl
module "example" {
  source = "./base_elements/module_name"
  
  # Required variables
  # ...
}
```

### 5. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Common Patterns

### Lambda Function with Multiple Layers

```hcl
module "layer1" {
  source     = "./base_elements/lambda_layer"
  layer_name = "utilities"
  filename   = "./layers/utils.zip"
  compatible_runtimes = ["python3.11"]
}

module "layer2" {
  source     = "./base_elements/lambda_layer"
  layer_name = "data-processing"
  filename   = "./layers/data.zip"
  compatible_runtimes = ["python3.11"]
}

module "function" {
  source        = "./base_elements/lambda_function"
  function_name = "processor"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "./function.zip"
  
  layers = [
    module.layer1.layer_arn,
    module.layer2.layer_arn
  ]
}
```

### Lambda Function in VPC with Custom IAM

```hcl
resource "aws_iam_policy" "custom" {
  name = "lambda-custom-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
}

module "vpc_function" {
  source = "./base_elements/lambda_function"

  function_name = "vpc-function"
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "./function.zip"
  
  vpc_config = {
    subnet_ids         = ["subnet-xxx", "subnet-yyy"]
    security_group_ids = ["sg-xxx"]
  }
  
  attach_policy_arns = [aws_iam_policy.custom.arn]
  
  timeout     = 60
  memory_size = 1024
}
```

## Best Practices

### 1. Variable Management

- Use `terraform.tfvars` for environment-specific values
- Never commit sensitive values to version control
- Use AWS Secrets Manager or Parameter Store for secrets

### 2. State Management

- Use remote state (S3 + DynamoDB)
- Enable state encryption
- Use separate state files per environment

### 3. Resource Naming

- Use consistent naming conventions
- Include environment in resource names
- Use tags for organization and cost tracking

### 4. Security

- Follow least privilege principle for IAM
- Enable encryption at rest and in transit
- Use VPC when accessing private resources
- Enable CloudWatch Logs for monitoring

### 5. Cost Optimization

- Right-size Lambda memory allocation
- Consider ARM64 architecture (20% cheaper)
- Set appropriate log retention periods
- Use reserved concurrency carefully

## Troubleshooting

### Common Issues

**Issue**: "Error creating Lambda function: InvalidParameterValueException"
- Check that your IAM role has a valid assume role policy
- Verify the handler path matches your code structure
- Ensure the runtime is correctly specified

**Issue**: "Error creating Lambda layer: InvalidParameterValueException"
- Verify the zip file structure matches AWS requirements
- Check that compatible_runtimes contains valid values
- Ensure the zip file is not corrupted

**Issue**: Lambda function timing out
- Increase the timeout value
- Check VPC configuration (NAT Gateway required for internet access)
- Review CloudWatch Logs for errors

**Issue**: Permission denied errors
- Review IAM role permissions
- Check resource policies (S3 bucket policies, etc.)
- Verify VPC security group rules

## Contributing

When adding new modules:

1. Follow the existing module structure
2. Include comprehensive README.md
3. Provide working examples
4. Use consistent variable naming
5. Add validation rules where appropriate
6. Document all inputs and outputs
7. Include best practices section

## Testing

Test your modules:

```bash
# Validate Terraform syntax
terraform validate

# Format code
terraform fmt -recursive

# Plan without applying
terraform plan

# Use Terratest for automated testing (recommended)
```

## Support

For issues, questions, or contributions:

- Review module documentation
- Check existing GitHub issues
- Open a new issue with detailed information

## License

This project is licensed under the MIT License.

## Authors

Created and maintained by Alok Kulkarni.

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

**Last Updated**: February 2026  
**Terraform Version**: >= 1.5.0  
**AWS Provider Version**: >= 5.0
