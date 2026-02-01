# Example: Lambda Function with Lambda Layer

This example demonstrates how to deploy a Lambda function that uses Lambda layers.

## What This Example Creates

- Lambda layer with Python dependencies
- Lambda function that uses the layer
- IAM role with necessary permissions
- CloudWatch Log Group for function logs

## Usage

1. **Prepare the layer package**:
```bash
cd lambda-layer-example
./build-layer.sh
```

2. **Prepare the function package**:
```bash
./build-function.sh
```

3. **Initialize Terraform**:
```bash
terraform init
```

4. **Plan the deployment**:
```bash
terraform plan
```

5. **Apply the configuration**:
```bash
terraform apply
```

6. **Test the function**:
```bash
aws lambda invoke \
  --function-name example-function-with-layer \
  --payload '{"key": "value"}' \
  response.json
cat response.json
```

## Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example variable values
- `build-layer.sh` - Script to build the layer package
- `build-function.sh` - Script to build the function package
- `layer/requirements.txt` - Python dependencies for the layer
- `function/app.py` - Lambda function code

## Clean Up

```bash
terraform destroy
```
