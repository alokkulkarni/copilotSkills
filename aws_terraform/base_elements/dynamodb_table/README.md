# DynamoDB Table Terraform Module

Production-ready Terraform module for deploying and managing AWS DynamoDB tables with comprehensive features including auto-scaling, streams, backups, Lambda integration, and data population.

## 📋 Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Module Structure](#module-structure)
- [Usage Examples](#usage-examples)
- [Variables](#variables)
- [Outputs](#outputs)
- [Scripts](#scripts)
- [Best Practices](#best-practices)

## ✨ Features

- **Flexible Billing**: Support for both PAY_PER_REQUEST and PROVISIONED billing modes
- **Auto-Scaling**: Automatic capacity scaling for provisioned tables
- **Global Tables**: Multi-region replication support
- **Indexes**: Global and Local Secondary Indexes
- **Streams**: DynamoDB Streams with Lambda triggers
- **Backup & Recovery**: AWS Backup integration and point-in-time recovery
- **Data Population**: Tools for seeding initial data
- **Lambda Integration**: Automatic IAM policy creation for Lambda access
- **Encryption**: Server-side encryption with KMS
- **TTL**: Time-to-live support
- **Monitoring**: CloudWatch integration for streams
- **Modular Design**: Separated concerns for easy maintenance

## 🚀 Quick Start

### Basic Table Deployment

```bash
# 1. Navigate to module directory
cd aws_terraform/base_elements/dynamodb_table

# 2. Initialize Terraform
terraform init

# 3. Deploy a simple table
terraform apply -var-file="examples/simple-table.tfvars"
```

### Using Deployment Script

```bash
# Deploy with automated script
./scripts/deploy-table.sh dev examples/simple-table.tfvars
```

## 📁 Module Structure

```
dynamodb_table/
├── main.tf                 # Core DynamoDB table resource
├── iam.tf                  # IAM policies for Lambda and other access
├── autoscaling.tf          # Auto-scaling configuration
├── data.tf                 # Data population resources
├── backup.tf               # Backup and recovery configuration
├── streams.tf              # DynamoDB Streams and triggers
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider version constraints
├── examples/               # Example configurations
│   ├── simple-table.tfvars
│   ├── table-with-gsi.tfvars
│   ├── table-with-lambda.tfvars
│   ├── provisioned-autoscaling.tfvars
│   ├── table-with-backup.tfvars
│   ├── global-table.tfvars
│   └── table-with-data.tfvars
├── scripts/                # Operational scripts
│   ├── deploy-table.sh
│   ├── setup-lambda-permissions.sh
│   ├── populate-data.sh
│   ├── backup-table.sh
│   └── validate-table.sh
├── README.md
├── OPERATIONS_GUIDE.md
└── STATE_MANAGEMENT.md
```

## 📚 Usage Examples

### Example 1: Simple On-Demand Table

```hcl
module "users_table" {
  source = "./dynamodb_table"

  table_name   = "users-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "timestamp"

  attributes = [
    { name = "userId", type = "S" },
    { name = "timestamp", type = "N" }
  ]

  enable_encryption      = true
  point_in_time_recovery = true
  ttl_enabled            = true
  ttl_attribute_name     = "expiryTime"

  tags = {
    Environment = "production"
    Application = "user-service"
  }
}
```

### Example 2: Table with Lambda Integration

```hcl
module "orders_table" {
  source = "./dynamodb_table"

  table_name   = "orders-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"

  attributes = [
    { name = "orderId", type = "S" }
  ]

  # Enable streams for Lambda processing
  stream_enabled             = true
  stream_view_type           = "NEW_AND_OLD_IMAGES"
  enable_stream_lambda_triggers = true

  stream_lambda_functions = {
    order_processor = {
      function_name     = "order-processing-lambda"
      starting_position = "LATEST"
      batch_size        = 10
    }
  }

  # Create IAM policies for Lambda access
  create_lambda_access_policy = true
  lambda_function_names       = ["order-processing-lambda", "analytics-lambda"]

  tags = {
    Environment = "production"
  }
}
```

### Example 3: Provisioned Table with Auto-Scaling

```hcl
module "analytics_table" {
  source = "./dynamodb_table"

  table_name     = "analytics-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "eventId"

  attributes = [
    { name = "eventId", type = "S" }
  ]

  # Enable auto-scaling
  enable_autoscaling            = true
  autoscaling_read_max_capacity = 100
  autoscaling_write_max_capacity = 100
  autoscaling_read_target       = 70
  autoscaling_write_target      = 70

  tags = {
    Environment = "production"
  }
}
```

## 📝 Targeted Operations

### Deploy Only Core Table

```bash
terraform apply -target=aws_dynamodb_table.this
```

### Deploy Table with IAM Policies

```bash
terraform apply \
  -target=aws_dynamodb_table.this \
  -target=aws_iam_policy.lambda_dynamodb_access \
  -target=aws_iam_role_policy_attachment.lambda_dynamodb_access
```

### Deploy Auto-Scaling Only

```bash
terraform apply \
  -target=aws_appautoscaling_target.table_read \
  -target=aws_appautoscaling_target.table_write \
  -target=aws_appautoscaling_policy.table_read \
  -target=aws_appautoscaling_policy.table_write
```

### Deploy Streams Configuration

```bash
terraform apply \
  -target=aws_lambda_event_source_mapping.dynamodb_stream
```

### Deploy Backup Configuration

```bash
terraform apply \
  -target=aws_backup_vault.dynamodb \
  -target=aws_backup_plan.dynamodb \
  -target=aws_backup_selection.dynamodb
```

## 🔧 Component Mapping

| Component | Primary File | Related Resources |
|-----------|-------------|-------------------|
| Table | main.tf | aws_dynamodb_table.this |
| IAM Policies | iam.tf | aws_iam_policy.lambda_dynamodb_access |
| Auto-Scaling | autoscaling.tf | aws_appautoscaling_target.*, aws_appautoscaling_policy.* |
| Data Population | data.tf | null_resource.populate_data, aws_dynamodb_table_item.static_items |
| Backups | backup.tf | aws_backup_vault.dynamodb, aws_backup_plan.dynamodb |
| Streams | streams.tf | aws_lambda_event_source_mapping.dynamodb_stream |

## 📋 Key Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `table_name` | Name of the DynamoDB table | - | Yes |
| `billing_mode` | PROVISIONED or PAY_PER_REQUEST | PAY_PER_REQUEST | No |
| `hash_key` | Partition key attribute name | - | Yes |
| `range_key` | Sort key attribute name | null | No |
| `attributes` | List of table attributes | - | Yes |
| `global_secondary_indexes` | List of GSI configurations | [] | No |
| `enable_encryption` | Enable server-side encryption | true | No |
| `point_in_time_recovery` | Enable PITR | true | No |
| `stream_enabled` | Enable DynamoDB Streams | false | No |
| `enable_autoscaling` | Enable capacity auto-scaling | false | No |
| `create_lambda_access_policy` | Create IAM policy for Lambda | false | No |
| `lambda_function_names` | Lambda functions to grant access | [] | No |

## 📤 Key Outputs

| Output | Description |
|--------|-------------|
| `table_id` | ID of the DynamoDB table |
| `table_arn` | ARN of the DynamoDB table |
| `table_name` | Name of the DynamoDB table |
| `table_stream_arn` | ARN of the table stream |
| `lambda_access_policy_arn` | ARN of Lambda access policy |
| `backup_vault_arn` | ARN of the backup vault |

## 🛠️ Scripts

### Deployment Script

Deploy DynamoDB table with comprehensive validation:

```bash
./scripts/deploy-table.sh <environment> <config-file>

# Example
./scripts/deploy-table.sh production examples/table-with-lambda.tfvars
```

### Lambda Permission Setup

Grant Lambda functions access to DynamoDB table:

```bash
./scripts/setup-lambda-permissions.sh <table-name> <lambda-function-names>

# Example
./scripts/setup-lambda-permissions.sh users-table "lambda1,lambda2,lambda3"
```

### Data Population

Populate table with JSON data:

```bash
./scripts/populate-data.sh <table-name> <data-file>

# Example
./scripts/populate-data.sh users-table data/users.json
```

**Data file format:**
```json
[
  {
    "userId": {"S": "user1"},
    "name": {"S": "John Doe"},
    "email": {"S": "john@example.com"}
  },
  {
    "userId": {"S": "user2"},
    "name": {"S": "Jane Smith"},
    "email": {"S": "jane@example.com"}
  }
]
```

### Table Backup

Create on-demand backup:

```bash
./scripts/backup-table.sh <table-name> [backup-name]

# Example
./scripts/backup-table.sh users-table backup-20260202
```

### Table Validation

Validate table configuration and health:

```bash
./scripts/validate-table.sh <table-name>

# Example
./scripts/validate-table.sh users-table
```

## 🎯 Best Practices

### 1. Billing Mode Selection

- **PAY_PER_REQUEST**: Use for unpredictable workloads, development/testing
- **PROVISIONED**: Use for consistent, predictable workloads with auto-scaling

### 2. Encryption

Always enable encryption at rest:
```hcl
enable_encryption = true
kms_key_arn       = aws_kms_key.dynamodb.arn  # Optional custom key
```

### 3. Point-in-Time Recovery

Enable PITR for production tables:
```hcl
point_in_time_recovery = true
```

### 4. Streams

Only enable streams when needed (adds cost):
```hcl
stream_enabled   = true
stream_view_type = "NEW_AND_OLD_IMAGES"  # Most comprehensive
```

### 5. Auto-Scaling

For PROVISIONED tables, always use auto-scaling:
```hcl
enable_autoscaling            = true
autoscaling_read_target       = 70  # Scale at 70% utilization
autoscaling_write_target      = 70
```

### 6. Indexes

- Use GSI for alternate query patterns
- Keep projection types minimal (use KEYS_ONLY or INCLUDE)
- Avoid over-indexing (costs storage and write capacity)

### 7. TTL

Use TTL to automatically expire old data:
```hcl
ttl_enabled        = true
ttl_attribute_name = "expiryTime"  # Unix timestamp
```

### 8. Tags

Always tag resources for cost allocation and management:
```hcl
tags = {
  Environment = "production"
  Application = "user-service"
  Team        = "backend"
  CostCenter  = "engineering"
  ManagedBy   = "terraform"
}
```

### 9. Deletion Protection

Enable for production tables:
```hcl
deletion_protection = true
```

### 10. Data Population

- Use `terraform_managed_items` for small, static configuration data
- Use `populate_data.sh` script for bulk data loading
- For large datasets (>25 items), use AWS SDK or CLI outside Terraform

## 🔍 Validation

Before deployment, validate your configuration:

```bash
# Validate Terraform syntax
terraform validate

# Preview changes
terraform plan -var-file="examples/your-config.tfvars"

# Format code
terraform fmt -recursive
```

After deployment, validate table health:

```bash
# Validate table configuration
./scripts/validate-table.sh your-table-name

# Check table status via AWS CLI
aws dynamodb describe-table --table-name your-table-name
```

## 📚 Additional Documentation

- [OPERATIONS_GUIDE.md](./OPERATIONS_GUIDE.md) - Step-by-step operational procedures
- [STATE_MANAGEMENT.md](./STATE_MANAGEMENT.md) - Terraform state backend setup

## 📖 References

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Terraform AWS Provider - DynamoDB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Streams](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html)

## 🤝 Support

For issues or questions:
1. Check the OPERATIONS_GUIDE.md for common procedures
2. Validate your configuration using the validation script
3. Review AWS CloudWatch logs for runtime issues
4. Consult the Terraform AWS provider documentation

## 📄 License

This module is maintained as part of the infrastructure codebase. Refer to the repository license for details.
