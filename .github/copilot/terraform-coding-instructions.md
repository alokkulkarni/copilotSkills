# Terraform Coding Standards and Guidelines

## Purpose
This document provides comprehensive Terraform coding standards and best practices for infrastructure as code (IaC) development. These guidelines ensure consistency, maintainability, security, and scalability across Terraform projects.

---

## Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Conventions](#naming-conventions)
3. [Code Organization](#code-organization)
4. [Variables and Configuration](#variables-and-configuration)
5. [Resource Management](#resource-management)
6. [State Management](#state-management)
7. [Modules](#modules)
8. [Version Management](#version-management)
9. [Security Best Practices](#security-best-practices)
10. [Documentation](#documentation)
11. [Testing and Validation](#testing-and-validation)
12. [Code Quality](#code-quality)
13. [Review Checklist](#review-checklist)

---

## 1. Project Structure

### Standard Directory Layout
```
terraform-project/
├── README.md
├── .gitignore
├── .terraform-version
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── backend.tf
├── provider.tf
├── locals.tf
├── data.tf
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   └── database/
└── resources/
    ├── iam/
    ├── security-groups/
    ├── kms/
    └── common/
```

### File Organization Guidelines
- **versions.tf**: Terraform and provider version constraints
- **provider.tf**: Provider configurations
- **backend.tf**: Backend configuration for state storage
- **main.tf**: Primary resource definitions
- **variables.tf**: All input variable declarations
- **outputs.tf**: All output value declarations
- **locals.tf**: Local values and computed variables
- **data.tf**: Data source definitions
- **resources/**: Generic/shared resources organized by type

---

## 2. Naming Conventions

### Resource Naming
- Use snake_case for all resource names
- Use descriptive, meaningful names that indicate purpose
- Include environment or context when appropriate
- Format: `<resource_type>_<descriptive_name>_<environment>`

**Examples:**
```hcl
resource "aws_vpc" "main_vpc_prod" {
  cidr_block = var.vpc_cidr
}

resource "aws_security_group" "web_server_sg_dev" {
  name = "web-server-sg-dev"
}
```

### Variable Naming
- Use snake_case for variable names
- Use descriptive names that clearly indicate purpose
- Prefix boolean variables with `enable_` or `is_`
- Use plural forms for list/set variables

**Examples:**
```hcl
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
```

### Module Naming
- Use kebab-case for module directory names
- Use clear, descriptive names indicating functionality
- Examples: `networking-vpc`, `compute-ec2`, `database-rds`

### Tag Naming
- Use PascalCase for tag keys
- Always include standard tags: `Name`, `Environment`, `ManagedBy`, `Project`
- Use consistent tag schema across all resources

**Example:**
```hcl
tags = merge(
  var.common_tags,
  {
    Name        = "web-server-prod"
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "ecommerce-platform"
  }
)
```

---

## 3. Code Organization

### File Structure Rules
1. **Single Responsibility**: Each file should have a clear, single purpose
2. **Logical Grouping**: Group related resources together
3. **Size Limit**: Keep files under 500 lines; split larger files logically
4. **Separation of Concerns**: Separate infrastructure layers (networking, compute, data)

### Resource Organization
```hcl
# Group related resources together with comments
# ============================================
# VPC Configuration
# ============================================
resource "aws_vpc" "main" {
  # resource configuration
}

resource "aws_subnet" "private" {
  # resource configuration
}

# ============================================
# Security Groups
# ============================================
resource "aws_security_group" "web" {
  # resource configuration
}
```

---

## 4. Variables and Configuration

### Variable Declaration Best Practices

#### Always Include Descriptions
```hcl
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}
```

#### Use Appropriate Variable Types
```hcl
# String
variable "region" {
  type = string
}

# Number
variable "instance_count" {
  type = number
}

# Boolean
variable "enable_encryption" {
  type = bool
}

# List
variable "subnet_ids" {
  type = list(string)
}

# Map
variable "tags" {
  type = map(string)
}

# Object
variable "database_config" {
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
  })
}
```

#### Use Validation Rules
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  
  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be from t2 or t3 family."
  }
}
```

#### Sensitive Variables
```hcl
variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

### Environment-Specific Variables
- Use `terraform.tfvars` for environment-specific values
- Never commit `terraform.tfvars` with sensitive data
- Provide `terraform.tfvars.example` as template
- Use separate tfvars files per environment in `environments/` directory

### Variable Defaults
- Provide sensible defaults for non-critical variables
- Do not provide defaults for environment-specific or sensitive variables
- Document why defaults are chosen

---

## 5. Resource Management

### Generic Resources Location
All generic/shared resources must be created in the `resources/` folder structure:

```
resources/
├── iam/
│   ├── roles.tf
│   ├── policies.tf
│   └── outputs.tf
├── security-groups/
│   ├── main.tf
│   └── outputs.tf
├── kms/
│   ├── keys.tf
│   └── outputs.tf
└── common/
    ├── s3-buckets.tf
    └── outputs.tf
```

### Resource Best Practices

#### Use Resource Dependencies Properly
```hcl
# Explicit dependency
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web_sg]
  # ...
}

# Implicit dependency (preferred)
resource "aws_instance" "web" {
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  # ...
}
```

#### Use Lifecycle Rules
```hcl
resource "aws_instance" "web" {
  # ...
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags["LastUpdated"]]
  }
}
```

#### Use Count and For_Each Appropriately
```hcl
# Use count for simple duplication
resource "aws_subnet" "private" {
  count             = var.az_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # ...
}

# Use for_each for map-based resources
resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  # ...
}
```

#### Avoid Hardcoded Values
```hcl
# BAD - Hardcoded values
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = "subnet-12345"
}

# GOOD - Parameterized values
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
}
```

---

## 6. State Management

### Backend Configuration
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "project/environment/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT:key/KEY-ID"
  }
}
```

### State Management Best Practices
1. **Always use remote state** for team collaboration
2. **Enable state locking** to prevent concurrent modifications
3. **Enable encryption** for state files
4. **Use workspaces** for environment separation when appropriate
5. **Regular state backups** should be automated
6. **Never commit state files** to version control
7. **Use separate state files** per environment

---

## 7. Modules

### Module Structure
```
modules/networking-vpc/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── examples/
    └── complete/
        ├── main.tf
        └── variables.tf
```

### Module Best Practices

#### Module README Template
```markdown
# Module Name

## Description
Brief description of what this module does.

## Usage
```hcl
module "vpc" {
  source = "./modules/networking-vpc"
  
  vpc_cidr = "10.0.0.0/16"
  environment = "prod"
}
```

## Requirements
- Terraform version
- Provider versions

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|

## Outputs
| Name | Description |
|------|-------------|
```

#### Module Input Variables
```hcl
# variables.tf in module
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}
```

#### Module Outputs
```hcl
# outputs.tf in module
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
```

#### Module Usage
```hcl
# Calling module from root
module "networking" {
  source = "./modules/networking-vpc"
  
  vpc_cidr           = var.vpc_cidr
  environment        = var.environment
  availability_zones = var.availability_zones
  
  tags = var.common_tags
}

# Reference module outputs
resource "aws_instance" "web" {
  subnet_id = module.networking.private_subnet_ids[0]
  # ...
}
```

### Module Design Principles
1. **Single Responsibility**: Each module should do one thing well
2. **Composability**: Modules should be composable and reusable
3. **No Hardcoded Values**: Everything should be parameterized
4. **Clear Interfaces**: Well-defined inputs and outputs
5. **Minimal Dependencies**: Reduce coupling between modules
6. **Version Pinning**: Use version constraints for module sources

---

## 8. Version Management

### Terraform Version Constraints
```hcl
# versions.tf
terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

### Version Pinning Best Practices
1. **Use Pessimistic Constraints**: `~>` operator for minor version updates
2. **Pin Major Versions**: Prevent breaking changes
3. **Regular Updates**: Keep providers up-to-date with latest stable versions
4. **Test Updates**: Always test provider updates in non-production first
5. **Document Versions**: Use `.terraform-version` file for tfenv/tenv

### .terraform-version File
```
1.6.6
```

---

## 9. Security Best Practices

### Secrets Management
```hcl
# BAD - Never hardcode secrets
resource "aws_db_instance" "database" {
  password = "hardcoded_password"  # NEVER DO THIS
}

# GOOD - Use variables marked as sensitive
resource "aws_db_instance" "database" {
  password = var.database_password
}

# BETTER - Use secrets manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_id
}

resource "aws_db_instance" "database" {
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

### Security Checklist
- [ ] No hardcoded credentials or API keys
- [ ] Sensitive variables marked as `sensitive = true`
- [ ] State file encryption enabled
- [ ] Secrets stored in secure vaults (AWS Secrets Manager, Vault)
- [ ] IAM policies follow principle of least privilege
- [ ] Security groups follow principle of least privilege
- [ ] Resources encrypted at rest and in transit
- [ ] Public access disabled unless explicitly required
- [ ] Logging and monitoring enabled
- [ ] Use of KMS keys for encryption

### Data Protection
```hcl
# Enable encryption
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

## 10. Documentation

### Code Comments
```hcl
# Use comments to explain WHY, not WHAT
# The code itself should be self-explanatory for WHAT

# Create VPC with DNS support enabled to allow private hosted zones
# This is required for internal service discovery
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

### Documentation Requirements
1. **README.md**: Project overview, setup instructions, usage
2. **Module Documentation**: Inputs, outputs, examples
3. **Inline Comments**: Complex logic, business requirements, workarounds
4. **Architecture Diagrams**: For complex infrastructure
5. **Change Log**: Document significant changes

### README Template
```markdown
# Project Name

## Overview
Brief description of the infrastructure managed by this Terraform code.

## Prerequisites
- Terraform >= 1.6.0
- AWS CLI configured
- Required permissions

## Directory Structure
Explain the directory organization.

## Usage
```bash
# Initialize
terraform init

# Plan
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply
terraform apply -var-file="environments/dev/terraform.tfvars"
```

## Environments
- dev
- staging
- prod

## Modules
List and describe modules used.

## Outputs
Document important outputs.

## Contributing
Guidelines for contributing.
```

---

## 11. Testing and Validation

### Pre-Commit Validation
```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Security scanning
tfsec .
checkov -d .

# Linting
tflint --recursive
```

### Testing Strategy
1. **Syntax Validation**: `terraform validate`
2. **Formatting**: `terraform fmt`
3. **Security Scanning**: `tfsec`, `checkov`
4. **Policy Validation**: Sentinel, OPA
5. **Plan Review**: Manual review of `terraform plan`
6. **Automated Tests**: Terratest for module testing

### Example Terratest (Go)
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

---

## 12. Code Quality

### Formatting Standards
```bash
# Auto-format all files
terraform fmt -recursive
```

### Linting
```hcl
# .tflint.hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}
```

### Code Review Checklist
- [ ] Code is properly formatted (`terraform fmt`)
- [ ] Code passes validation (`terraform validate`)
- [ ] No hardcoded values
- [ ] All variables have descriptions
- [ ] Sensitive data properly handled
- [ ] Outputs documented
- [ ] Module documentation complete
- [ ] Security best practices followed
- [ ] Resource naming conventions followed
- [ ] Proper tagging applied
- [ ] State backend configured
- [ ] Provider versions pinned
- [ ] No security vulnerabilities (tfsec/checkov)

---

## 13. Review Checklist

### General
- [ ] Project follows standard directory structure
- [ ] README.md is complete and up-to-date
- [ ] .gitignore includes Terraform-specific files
- [ ] .terraform-version file present

### Code Organization
- [ ] Files organized logically (versions.tf, provider.tf, main.tf, etc.)
- [ ] Resources grouped logically with comments
- [ ] Generic resources in `resources/` folder
- [ ] Modules in `modules/` folder
- [ ] Environment configs in `environments/` folder

### Variables and Configuration
- [ ] All variables have descriptions
- [ ] Appropriate variable types used
- [ ] Validation rules for critical variables
- [ ] Sensitive variables marked as sensitive
- [ ] No default values for sensitive/environment-specific variables
- [ ] terraform.tfvars.example provided
- [ ] No hardcoded values in resources

### Version Management
- [ ] Terraform version constraint defined
- [ ] All provider versions pinned
- [ ] Using latest stable versions
- [ ] Pessimistic version constraints used (~>)

### State Management
- [ ] Remote backend configured
- [ ] State locking enabled
- [ ] State encryption enabled
- [ ] Separate state per environment

### Modules
- [ ] Modules follow single responsibility principle
- [ ] Module README complete
- [ ] Module variables documented
- [ ] Module outputs documented
- [ ] Module examples provided
- [ ] No hardcoded values in modules

### Security
- [ ] No hardcoded secrets or credentials
- [ ] Sensitive variables properly marked
- [ ] Encryption enabled where applicable
- [ ] Security groups follow least privilege
- [ ] IAM policies follow least privilege
- [ ] Public access disabled unless required
- [ ] Logging and monitoring enabled
- [ ] Passes security scanning (tfsec/checkov)

### Documentation
- [ ] Code comments explain WHY, not WHAT
- [ ] Complex logic documented
- [ ] Module documentation complete
- [ ] README includes usage examples
- [ ] Architecture documented if complex

### Testing
- [ ] Code formatted (`terraform fmt`)
- [ ] Code validated (`terraform validate`)
- [ ] Security scanned (tfsec/checkov)
- [ ] Linting passed (tflint)
- [ ] Plan reviewed manually

### Naming Conventions
- [ ] Resources use snake_case
- [ ] Variables use snake_case
- [ ] Modules use kebab-case
- [ ] Tags use PascalCase
- [ ] Standard tags applied (Name, Environment, ManagedBy, Project)

### Best Practices
- [ ] DRY principle followed
- [ ] Resources modular and reusable
- [ ] Proper use of count/for_each
- [ ] Lifecycle rules used where appropriate
- [ ] Proper dependency management
- [ ] Outputs well-defined

---

## Additional Guidelines

### Performance Optimization
1. Use data sources efficiently
2. Minimize provider API calls
3. Use `-parallelism` flag appropriately
4. Cache provider plugins

### Troubleshooting
1. Use `TF_LOG` for debugging
2. Review terraform plan carefully
3. Check provider documentation
4. Validate credentials and permissions

### CI/CD Integration
1. Automate formatting checks
2. Run validation in pipeline
3. Perform security scanning
4. Generate and review plans
5. Require approval for applies
6. Automate state backups

---

## Resources and References

### Official Documentation
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Tools
- **tflint**: Terraform linter
- **tfsec**: Security scanner
- **checkov**: Policy and security scanner
- **terratest**: Testing framework
- **terraform-docs**: Documentation generator
- **infracost**: Cost estimation

### Best Practice Guides
- [Terraform Best Practices by Gruntwork](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Version:** 1.0  
**Last Updated:** 2026-02-01  
**Maintained By:** DevOps Team
