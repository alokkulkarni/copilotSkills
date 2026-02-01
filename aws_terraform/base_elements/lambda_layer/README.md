# AWS Lambda Layer Terraform Module

## Description

This module creates an AWS Lambda Layer that can be shared across multiple Lambda functions. Lambda layers allow you to package libraries, custom runtimes, or other dependencies separately from your function code, promoting code reuse and reducing deployment package sizes.

## Features

- ✅ Support for local file or S3-based layer deployment
- ✅ Multiple runtime compatibility
- ✅ Automatic versioning
- ✅ Optional cross-account layer sharing permissions
- ✅ Source code hash tracking for change detection
- ✅ License information support

## Usage

### Basic Usage with Local File

```hcl
module "python_utils_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "python-utils-layer"
  description         = "Common Python utilities and dependencies"
  filename            = "${path.module}/layers/python-utils.zip"
  compatible_runtimes = ["python3.9", "python3.10", "python3.11"]
  license_info        = "MIT"
}
```

### Usage with S3 Bucket

```hcl
module "nodejs_dependencies_layer" {
  source = "./base_elements/lambda_layer"

  layer_name        = "nodejs-dependencies-layer"
  description       = "Node.js dependencies and libraries"
  s3_bucket         = "my-lambda-layers-bucket"
  s3_key            = "layers/nodejs-dependencies-v1.0.0.zip"
  s3_object_version = "abc123xyz"
  compatible_runtimes = ["nodejs18.x", "nodejs20.x"]
}
```

### With Cross-Account Permissions

```hcl
module "shared_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "shared-utilities-layer"
  description         = "Shared utilities for multiple accounts"
  filename            = "${path.module}/layers/shared-utils.zip"
  compatible_runtimes = ["python3.11"]

  # Enable cross-account access
  enable_layer_permissions = true
  permission_principal     = "123456789012"  # Target AWS account ID
  permission_statement_id  = "AllowAccountAccess"
}
```

### Using Layer in Lambda Function

```hcl
module "lambda_layer" {
  source = "./base_elements/lambda_layer"

  layer_name          = "my-layer"
  filename            = "./layer.zip"
  compatible_runtimes = ["python3.11"]
}

module "lambda_function" {
  source = "./base_elements/lambda_function"

  function_name = "my-function"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "./function.zip"

  # Attach the layer
  layers = [module.lambda_layer.layer_arn]
}
```

## Layer Package Structure

Your layer zip file should follow AWS Lambda's expected structure:

### Python Layer Structure
```
python-layer.zip
└── python/
    ├── lib/
    │   └── python3.11/
    │       └── site-packages/
    │           ├── requests/
    │           ├── boto3/
    │           └── ...
    └── requirements.txt
```

### Node.js Layer Structure
```
nodejs-layer.zip
└── nodejs/
    ├── node_modules/
    │   ├── axios/
    │   ├── lodash/
    │   └── ...
    └── package.json
```

### Creating a Python Layer Locally

```bash
# Create layer directory structure
mkdir -p python/lib/python3.11/site-packages

# Install dependencies
pip install -r requirements.txt -t python/lib/python3.11/site-packages/

# Create zip file
zip -r python-layer.zip python/
```

### Creating a Node.js Layer Locally

```bash
# Create layer directory structure
mkdir nodejs

# Install dependencies
cd nodejs
npm install axios lodash

# Create zip file
cd ..
zip -r nodejs-layer.zip nodejs/
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
| layer_name | Unique name for the Lambda layer | `string` | n/a | yes |
| description | Description of the Lambda layer | `string` | `""` | no |
| filename | Path to the local zip file containing the layer code | `string` | `null` | no* |
| s3_bucket | S3 bucket containing the layer code | `string` | `null` | no* |
| s3_key | S3 key of the layer code zip file | `string` | `null` | no* |
| s3_object_version | S3 object version of the layer code | `string` | `null` | no |
| source_code_hash | Base64-encoded SHA256 hash of the layer code | `string` | `null` | no |
| compatible_runtimes | List of Lambda runtimes that can use this layer | `list(string)` | `[]` | no |
| license_info | License information for the layer | `string` | `null` | no |
| enable_layer_permissions | Enable permissions for other AWS accounts | `bool` | `false` | no |
| permission_action | Lambda API action for layer permission | `string` | `"lambda:GetLayerVersion"` | no |
| permission_principal | AWS principal allowed to use the layer | `string` | `"*"` | no |
| organization_id | AWS organization ID to grant layer permissions | `string` | `null` | no |
| permission_statement_id | Unique statement ID for the layer permission | `string` | `"AllowLayerAccess"` | no |

*Note: Either `filename` OR `s3_bucket` + `s3_key` must be provided.

## Outputs

| Name | Description |
|------|-------------|
| layer_arn | ARN of the Lambda layer version (use this to attach to Lambda functions) |
| layer_version | Version number of the Lambda layer |
| layer_name | Name of the Lambda layer |
| created_date | Date the layer version was created |
| source_code_size | Size of the layer code in bytes |
| compatible_runtimes | List of compatible runtimes for this layer |
| signing_profile_version_arn | ARN of the signing profile version (if code signing is enabled) |
| signing_job_arn | ARN of the signing job (if code signing is enabled) |

## Supported Runtimes

AWS Lambda supports the following runtimes for layers:

- **Python**: python3.8, python3.9, python3.10, python3.11, python3.12
- **Node.js**: nodejs16.x, nodejs18.x, nodejs20.x
- **Java**: java8, java8.al2, java11, java17, java21
- **Ruby**: ruby2.7, ruby3.2
- **Go**: provided.al2, provided.al2023
- **.NET**: dotnet6, dotnet8
- **Custom Runtime**: provided, provided.al2, provided.al2023

## Layer Size Limits

- Unzipped layer size: 250 MB (including all layers)
- Total unzipped function + layers: 250 MB
- Zipped deployment package: 50 MB (direct upload), 250 MB (S3)

## Best Practices

1. **Version Control**: Use `source_code_hash` to trigger updates when layer content changes
2. **Runtime Compatibility**: Only specify runtimes that you've tested with the layer
3. **Size Optimization**: Keep layers small by including only necessary dependencies
4. **Separation of Concerns**: Create separate layers for different types of dependencies
5. **Naming Convention**: Use descriptive names indicating the layer's purpose
6. **Documentation**: Include a README or license file in your layer package
7. **Testing**: Test layers with your Lambda functions before deploying to production
8. **Versioning**: Use semantic versioning in layer names for easier management

## Common Use Cases

### Shared Dependencies
Package common libraries used across multiple Lambda functions:
- requests, boto3 for Python
- axios, lodash for Node.js

### Custom Runtimes
Create custom runtime layers for languages not natively supported by Lambda.

### Third-Party Libraries
Bundle heavy dependencies separately to reduce individual function deployment sizes.

### Configuration Files
Share configuration files, certificates, or other static assets.

## Troubleshooting

### Layer Not Found by Function
- Ensure the layer runtime matches the function runtime
- Verify the layer ARN is correctly referenced
- Check that the layer is in the same region as the function

### Import Errors
- Verify the layer directory structure matches AWS requirements
- Check that Python paths are correct (python/lib/pythonX.X/site-packages/)
- Ensure Node.js modules are in nodejs/node_modules/

### Size Limit Exceeded
- Remove unnecessary dependencies
- Use lighter-weight alternatives
- Split into multiple layers

## Examples

See the `examples/` directory for complete working examples:
- `examples/python-layer/` - Python dependencies layer
- `examples/nodejs-layer/` - Node.js dependencies layer
- `examples/shared-layer/` - Cross-account shared layer

## License

This module is licensed under the MIT License.

## Authors

Created and maintained by Alok Kulkarni.

## References

- [AWS Lambda Layers Documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
- [Lambda Layer Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform AWS Lambda Layer Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version)
