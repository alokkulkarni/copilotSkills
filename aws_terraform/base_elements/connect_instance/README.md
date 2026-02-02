# AWS Connect Instance Terraform Module

This Terraform module deploys and configures an Amazon Connect instance with full support for phone numbers, contact flows, queues, routing profiles, security profiles, users, and integrations with AWS Lambda and Amazon Lex.

## Quick Start Command Reference

### Most Common Operations

```bash
# Initialize with S3 backend
terraform init

# Plan/Apply specific components
terraform apply -target=module.connect.aws_connect_phone_number.phone_numbers      # Phone numbers only
terraform apply -target=module.connect.aws_connect_user.users                       # Users only
terraform apply -target=module.connect.aws_connect_queue.queues                     # Queues only
terraform apply -target=module.connect.aws_connect_contact_flow.contact_flows       # Contact flows only

# Verify state
terraform state list                                                                # List all resources
terraform state show 'module.connect.aws_connect_instance.this'                     # Show instance details

# Check S3 state
aws s3 ls s3://my-terraform-state-bucket/connect-instance/                          # List state files
```

**📘 For detailed command reference, see [Terraform Commands and State Management](#terraform-commands-and-state-management) section below.**  
**📕 For step-by-step operational procedures, see [OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md).**  
**📗 For complete S3 state management guide, see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md).**

## Table of Contents

- [Module Structure](#module-structure)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- **[📘 Terraform Commands and State Management](#terraform-commands-and-state-management)** ⭐
  - [Backend Configuration for S3 State](#backend-configuration-for-s3-state)
  - [Targeted Terraform Operations](#targeted-terraform-operations)
  - [State Inspection Commands](#state-inspection-commands)
  - [Verifying S3 State Consistency](#verifying-s3-state-consistency)
- **[📋 Module-Level vs Component-Level Operations](#module-level-vs-component-level-operations)** ⭐
- [Working with Individual Components](#working-with-individual-components)
- [Usage](#usage)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

### 📚 Additional Documentation

- **[OPERATIONS_GUIDE.md](OPERATIONS_GUIDE.md)** - Step-by-step procedures for common operational tasks (adding users, phone numbers, updating flows, etc.)
- **[STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)** - Complete guide for S3 state backend setup, verification, disaster recovery, and troubleshooting

## Module Structure

The module is organized into separate, focused files for better maintainability and independent management:

```
connect_instance/
├── main.tf                    # Core Connect instance resource
├── iam.tf                     # IAM roles and policies
├── logging.tf                 # CloudWatch log groups
├── hours_of_operation.tf      # Business hours configuration
├── queues.tf                  # Queue resources
├── routing_profiles.tf        # Agent routing configuration
├── security_profiles.tf       # User permissions and access control
├── quick_connects.tf          # Transfer destinations (phone/queue/user)
├── phone_numbers.tf           # Phone number provisioning
├── contact_flows.tf           # Call flow logic
├── users.tf                   # User and hierarchy management
├── integrations.tf            # Lambda and Lex bot associations
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider version constraints
└── README.md                  # This file
```

### Benefits of Modular Structure

- **Focused Changes**: Modify security profiles without touching user management
- **Clear Separation**: Each file has a single, well-defined responsibility
- **Easy Navigation**: Quickly locate resources by category
- **Independent Testing**: Test and validate specific components
- **Better Reviews**: Code reviews focus on specific areas of change
- **Team Collaboration**: Multiple team members can work on different components

## Features

- ✅ **Complete Connect Instance Deployment**: Deploy a fully configured Amazon Connect contact center instance
- ✅ **Phone Number Provisioning**: Claim and configure phone numbers (DID and toll-free) with country code support
- ✅ **Contact Flow Management**: Create and manage contact flows with inline JSON or file-based configuration
- ✅ **Queue Configuration**: Set up queues with hours of operation, max contacts, and outbound caller ID
- ✅ **Routing Profiles**: Define how contacts are distributed to agents with media concurrency settings
- ✅ **Security Profiles**: Create role-based access control with granular permissions
- ✅ **User Management**: Provision admin and regular users with automatic profile assignment
- ✅ **Quick Connects**: Configure quick connects for transfers to queues, users, or external numbers
- ✅ **Lambda Integration**: Associate Lambda functions for custom contact flow logic
- ✅ **Lex Bot Integration**: Connect Amazon Lex bots for conversational AI capabilities
- ✅ **Hours of Operation**: Define business hours for queue availability
- ✅ **User Hierarchy Groups**: Organize users into teams and departments
- ✅ **CloudWatch Logging**: Automatic contact flow logging for debugging and monitoring
- ✅ **Contact Lens**: Optional analytics and sentiment analysis capabilities
- ✅ **Flexible Configuration**: Enable/disable features via boolean flags

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Amazon Connect Instance                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Phone Numbers│  │Contact Flows │  │    Queues    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Routing    │  │  Security    │  │ Quick        │     │
│  │   Profiles   │  │  Profiles    │  │ Connects     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Users     │  │  Hierarchy   │  │    Hours     │     │
│  │              │  │   Groups     │  │ of Operation │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                    ▲              ▲
                    │              │
            ┌───────┴──────┐  ┌───┴──────┐
            │ AWS Lambda   │  │ Amazon   │
            │  Functions   │  │ Lex Bots │
            └──────────────┘  └──────────┘
```

## Prerequisites

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- AWS CLI configured with appropriate permissions
- Amazon Connect service quota for your region

## Terraform Commands and State Management

### Backend Configuration for S3 State

**IMPORTANT**: Always configure an S3 backend to maintain Terraform state correctly. Add this to your root module (not in the base_elements module):

```hcl
# backend.tf in your root module
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "connect-instance/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    # Optional: versioning enabled on S3 bucket recommended
  }
}
```

### State Management Best Practices

1. **Initialize Backend**:
   ```bash
   terraform init
   ```

2. **Verify State Location**:
   ```bash
   terraform state list
   ```

3. **View State File in S3**:
   ```bash
   aws s3 ls s3://my-terraform-state-bucket/connect-instance/
   ```

4. **Enable S3 Versioning** (for state recovery):
   ```bash
   aws s3api put-bucket-versioning \
     --bucket my-terraform-state-bucket \
     --versioning-configuration Status=Enabled
   ```

## Targeted Terraform Operations

One of the key benefits of the modular structure is the ability to operate on specific resources without affecting others. Use Terraform's `-target` flag for surgical updates.

### Operating on Specific Components

#### Working with Phone Numbers Only

**Plan changes to phone numbers:**
```bash
terraform plan -target=module.connect.aws_connect_phone_number.phone_numbers
```

**Apply phone number changes:**
```bash
terraform apply -target=module.connect.aws_connect_phone_number.phone_numbers
```

**Add a new phone number without touching other resources:**
```bash
# Edit your tfvars to add phone number
terraform apply -target='module.connect.aws_connect_phone_number.phone_numbers["new_number"]'
```

#### Working with Users Only

**Plan user changes:**
```bash
terraform plan \
  -target=module.connect.aws_connect_user_hierarchy_group.hierarchy_groups \
  -target=module.connect.aws_connect_user.users
```

**Apply user changes:**
```bash
terraform apply \
  -target=module.connect.aws_connect_user_hierarchy_group.hierarchy_groups \
  -target=module.connect.aws_connect_user.users
```

**Add a single user:**
```bash
terraform apply -target='module.connect.aws_connect_user.users["agent.name"]'
```

#### Working with Security Profiles Only

**Update security profiles:**
```bash
terraform plan -target=module.connect.aws_connect_security_profile.security_profiles
terraform apply -target=module.connect.aws_connect_security_profile.security_profiles
```

#### Working with Contact Flows Only

**Update contact flows:**
```bash
terraform plan -target=module.connect.aws_connect_contact_flow.contact_flows
terraform apply -target=module.connect.aws_connect_contact_flow.contact_flows
```

**Update a specific contact flow:**
```bash
terraform apply -target='module.connect.aws_connect_contact_flow.contact_flows["main_flow"]'
```

#### Working with Queues Only

**Update queues without affecting routing:**
```bash
terraform plan -target=module.connect.aws_connect_queue.queues
terraform apply -target=module.connect.aws_connect_queue.queues
```

#### Working with Routing Profiles Only

**Update routing profiles:**
```bash
terraform plan -target=module.connect.aws_connect_routing_profile.routing_profiles
terraform apply -target=module.connect.aws_connect_routing_profile.routing_profiles
```

#### Working with Lambda/Lex Integrations Only

**Update integrations:**
```bash
# Lambda functions
terraform apply -target=module.connect.aws_connect_lambda_function_association.lambda_functions

# Lex bots
terraform apply -target=module.connect.aws_connect_bot_association.lex_bots
```

#### Working with Quick Connects Only

**Update transfer destinations:**
```bash
terraform plan -target=module.connect.aws_connect_quick_connect.quick_connects
terraform apply -target=module.connect.aws_connect_quick_connect.quick_connects
```

### Advanced Targeted Operations

#### Multiple Component Updates

**Update users and their routing profiles together:**
```bash
terraform apply \
  -target=module.connect.aws_connect_routing_profile.routing_profiles \
  -target=module.connect.aws_connect_user.users
```

**Update phone numbers and queues together:**
```bash
terraform apply \
  -target=module.connect.aws_connect_phone_number.phone_numbers \
  -target=module.connect.aws_connect_queue.queues
```

#### Dry Run and Validation

**Preview changes without state lock:**
```bash
terraform plan -target=module.connect.aws_connect_user.users -lock=false
```

**Validate configuration before apply:**
```bash
terraform validate
terraform fmt -check
```

#### Refresh State for Specific Resources

**Refresh phone number state from AWS:**
```bash
terraform refresh -target=module.connect.aws_connect_phone_number.phone_numbers
```

**Refresh entire Connect instance state:**
```bash
terraform refresh -target=module.connect
```

### State Inspection Commands

#### List All Resources

```bash
# List all resources in state
terraform state list

# Filter for specific resource types
terraform state list | grep aws_connect_user
terraform state list | grep aws_connect_phone_number
terraform state list | grep aws_connect_queue
```

#### Inspect Resource Details

```bash
# Show specific resource details
terraform state show 'module.connect.aws_connect_instance.this'
terraform state show 'module.connect.aws_connect_user.users["agent.name"]'
terraform state show 'module.connect.aws_connect_queue.queues["support"]'
```

#### Move Resources in State

```bash
# Rename a resource in state (if refactoring)
terraform state mv \
  'module.connect.aws_connect_user.users["old_name"]' \
  'module.connect.aws_connect_user.users["new_name"]'
```

#### Remove Resources from State

```bash
# Remove without destroying (if managed elsewhere)
terraform state rm 'module.connect.aws_connect_user.users["external_user"]'
```

### Import Existing Resources

If you have existing Connect resources not in Terraform:

```bash
# Import Connect instance
terraform import module.connect.aws_connect_instance.this arn:aws:connect:eu-west-2:123456789012:instance/12345678-1234-1234-1234-123456789012

# Import phone number
terraform import 'module.connect.aws_connect_phone_number.phone_numbers["main"]' 12345678-1234-1234-1234-123456789012/87654321-4321-4321-4321-210987654321

# Import user
terraform import 'module.connect.aws_connect_user.users["agent"]' 12345678-1234-1234-1234-123456789012/user-id-here
```

### Verifying S3 State Consistency

After targeted operations, verify state is correctly stored:

```bash
# Check state file metadata in S3
aws s3api head-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate

# Download and inspect state (for debugging)
aws s3 cp s3://my-terraform-state-bucket/connect-instance/terraform.tfstate ./local-state.tfstate
terraform state list -state=./local-state.tfstate

# Verify state lock (DynamoDB)
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}'
```

### Common Workflow Patterns

#### Safe Production Updates

```bash
# 1. Create a plan file
terraform plan -out=connect-updates.tfplan

# 2. Review the plan
terraform show connect-updates.tfplan

# 3. Apply the reviewed plan
terraform apply connect-updates.tfplan
```

#### Emergency User Addition

```bash
# Quickly add a user in emergency
terraform apply \
  -target='module.connect.aws_connect_user.users["emergency.agent"]' \
  -auto-approve
```

#### Rollback Using State Versioning

```bash
# List state versions in S3
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate

# Download previous version
aws s3api get-object \
  --bucket my-terraform-state-bucket \
  --key connect-instance/terraform.tfstate \
  --version-id <version-id> \
  ./previous-state.tfstate

# Push previous state (use with extreme caution)
terraform state push ./previous-state.tfstate
```

## Working with Individual Components

The modular structure allows you to focus on specific components. Here's how to work with each:

### Adding Security Profiles

Edit [security_profiles.tf](security_profiles.tf):

```hcl
# Add new security profiles via variables
security_profiles = [
  {
    name        = "TeamLeadProfile"
    description = "Team lead with additional permissions"
    permissions = [
      "BasicAgentAccess",
      "OutboundCallAccess",
      "AccessMetrics",
      "ManagerListenIn"
    ]
  }
]
```

### Adding Phone Numbers

Edit [phone_numbers.tf](phone_numbers.tf) or configure via variables:

```hcl
# Add phone numbers via variables
phone_numbers = {
  support_line = {
    country_code = "GB"
    type         = "DID"
    description  = "Dedicated support line"
  }
  emergency_line = {
    country_code = "GB"
    type         = "TOLL_FREE"
    description  = "24/7 emergency hotline"
  }
}
```

### Adding Contact Flows

Edit [contact_flows.tf](contact_flows.tf) or configure via variables:

```hcl
# Add contact flows via variables
contact_flows = [
  {
    name        = "VIPCustomerFlow"
    description = "Priority routing for VIP customers"
    type        = "CONTACT_FLOW"
    filename    = "./flows/vip-flow.json"
  }
]
```

### Adding Users

Edit [users.tf](users.tf) or configure via variables:

```hcl
# Add users via variables
users = [
  {
    username                 = "new.agent"
    email                    = "new.agent@example.com"
    first_name              = "New"
    last_name               = "Agent"
    phone_type              = "SOFT_PHONE"
    routing_profile_name    = "SalesAgentProfile"
    security_profile_names  = ["SalesAgentAccess"]
    hierarchy_group_name    = "Sales"
  }
]
```

### Adding Queues

Edit [queues.tf](queues.tf) or configure via variables:

```hcl
# Add queues via variables
queues = [
  {
    name                    = "PremiumSupportQueue"
    description             = "Premium customer support queue"
    hours_of_operation_name = "ExtendedHours"
    max_contacts            = 50
    status                  = "ENABLED"
  }
]
```

### Adding Lambda Integrations

Edit [integrations.tf](integrations.tf) or configure via variables:

```hcl
# Add Lambda functions via variables
lambda_functions = {
  customer_validation = {
    function_arn = "arn:aws:lambda:eu-west-2:123456789012:function:ValidateCustomer"
  }
}
```

### Adding Lex Bot Integrations

Edit [integrations.tf](integrations.tf) or configure via variables:

```hcl
# Add Lex bots via variables
lex_bots = [
  {
    name       = "CustomerServiceBot"
    lex_region = "eu-west-2"
  }
]
```

## Usage

### Basic Instance

Create a minimal Connect instance:

```hcl
module "connect" {
  source = "./base_elements/connect_instance"

  instance_alias           = "my-contact-center"
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
  
  tags = {
    Environment = "production"
    Project     = "customer-service"
    ManagedBy   = "terraform"
  }
}
```

### Full Contact Center with All Features

```hcl
module "connect" {
  source = "./base_elements/connect_instance"

  # Core configuration
  instance_alias              = "full-contact-center"
  identity_management_type    = "CONNECT_MANAGED"
  inbound_calls_enabled       = true
  outbound_calls_enabled      = true
  contact_flow_logs_enabled   = true
  contact_lens_enabled        = true
  early_media_enabled         = true
  multi_party_conference_enabled = true

  # Hours of operation
  hours_of_operation = [
    {
      name        = "UK Business Hours"
      description = "Monday to Friday, 9 AM to 5 PM GMT"
      time_zone   = "Europe/London"
      config = [
        {
          day        = "MONDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        }
      ]
    }
  ]

  # Phone numbers
  phone_numbers = {
    main_line = {
      country_code = "GB"
      type         = "DID"
      description  = "Main customer service line"
    }
    toll_free = {
      country_code = "GB"
      type         = "TOLL_FREE"
      description  = "Toll-free support line"
    }
  }

  # Queues
  queues = [
    {
      name                          = "CustomerService"
      description                   = "Main customer service queue"
      hours_of_operation_name       = "UK Business Hours"
      max_contacts                  = 100
      outbound_caller_id_name       = "Customer Service"
      outbound_caller_id_number_key = "main_line"
      status                        = "ENABLED"
      quick_connect_keys            = ["supervisor"]
    }
  ]

  # Routing profiles
  routing_profiles = [
    {
      name                        = "AgentProfile"
      description                 = "Standard agent routing profile"
      default_outbound_queue_name = "CustomerService"
      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        },
        {
          channel     = "CHAT"
          concurrency = 3
        }
      ]
      queue_configs = [
        {
          channel    = "VOICE"
          delay      = 0
          priority   = 1
          queue_name = "CustomerService"
        }
      ]
    }
  ]

  # Security profiles
  security_profiles = [
    {
      name        = "AgentProfile"
      description = "Standard agent permissions"
      permissions = [
        "BasicAgentAccess",
        "OutboundCallAccess"
      ]
    }
  ]

  # Quick connects
  quick_connects = {
    supervisor = {
      name        = "Supervisor"
      description = "Quick connect to supervisor queue"
      type        = "QUEUE"
      queue_name  = "CustomerService"
    }
  }

  # Users
  users = [
    {
      username                 = "john.smith"
      email                    = "john.smith@example.com"
      first_name              = "John"
      last_name               = "Smith"
      phone_type              = "SOFT_PHONE"
      routing_profile_name    = "AgentProfile"
      security_profile_names  = ["AgentProfile"]
    }
  ]

  # Admin user
  create_admin_user = true
  admin_user = {
    username   = "admin"
    email      = "admin@example.com"
    first_name = "Admin"
    last_name  = "User"
  }

  # Contact flows
  contact_flows = [
    {
      name        = "MainFlow"
      description = "Main customer service flow"
      type        = "CONTACT_FLOW"
      filename    = "./contact-flows/main-flow.json"
    }
  ]

  # Lambda integrations
  lambda_functions = {
    customer_lookup = {
      function_arn = module.lambda.function_arn
    }
  }

  # Lex bot integrations
  lex_bots = [
    {
      name       = "CustomerServiceBot"
      lex_region = "eu-west-2"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "customer-service"
    ManagedBy   = "terraform"
  }
}
```

### Integration with Lex Bot Module

```hcl
# Deploy Lex bot
module "lex_bot" {
  source = "../lex_bot"

  bot_name        = "CustomerServiceBot"
  bot_description = "Customer service chatbot"
  # ... other Lex configuration
}

# Deploy Connect instance with Lex integration
module "connect" {
  source = "./base_elements/connect_instance"

  instance_alias = "my-contact-center"
  
  lex_bots = [
    {
      name       = module.lex_bot.bot_name
      lex_region = "eu-west-2"
    }
  ]
  
  depends_on = [module.lex_bot]
}
```

### Integration with Lambda Module

```hcl
# Deploy Lambda function
module "lambda" {
  source = "../lambda_function"

  function_name = "connect-customer-lookup"
  runtime       = "python3.11"
  handler       = "index.handler"
  # ... other Lambda configuration
}

# Deploy Connect instance with Lambda integration
module "connect" {
  source = "./base_elements/connect_instance"

  instance_alias = "my-contact-center"
  
  lambda_functions = {
    customer_lookup = {
      function_arn = module.lambda.function_arn
    }
  }
  
  depends_on = [module.lambda]
}
```

## Regional Considerations

### UK Deployment (eu-west-2)

When deploying to the UK region:

```hcl
module "connect" {
  source = "./base_elements/connect_instance"

  instance_alias = "uk-contact-center"
  
  # Use UK phone numbers
  phone_numbers = {
    main = {
      country_code = "GB"
      type         = "DID"
      description  = "UK main line"
    }
  }
  
  # Use UK timezone
  hours_of_operation = [
    {
      name      = "UK Business Hours"
      time_zone = "Europe/London"
      # ... configuration
    }
  ]
  
  # Ensure Lex bots are in same region
  lex_bots = [
    {
      name       = "UKBot"
      lex_region = "eu-west-2"
    }
  ]
}
```

## Variables

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `instance_alias` | Alias for the Connect instance (must be unique) | `string` | n/a | yes |
| `identity_management_type` | Identity management type | `string` | `"CONNECT_MANAGED"` | no |
| `inbound_calls_enabled` | Enable inbound calling | `bool` | `true` | no |
| `outbound_calls_enabled` | Enable outbound calling | `bool` | `true` | no |
| `contact_flow_logs_enabled` | Enable contact flow logs in CloudWatch | `bool` | `true` | no |
| `contact_lens_enabled` | Enable Contact Lens analytics | `bool` | `false` | no |
| `auto_resolve_best_voices_enabled` | Enable auto resolve best voices for TTS | `bool` | `true` | no |
| `early_media_enabled` | Enable early media | `bool` | `true` | no |
| `multi_party_conference_enabled` | Enable multi-party conference | `bool` | `false` | no |
| `log_retention_days` | CloudWatch log retention period in days | `number` | `7` | no |
| `connect_iam_policy_arn` | IAM policy ARN for Connect instance role | `string` | `AmazonConnect_FullAccess` | no |

### Hours of Operation

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `hours_of_operation` | List of hours of operation configurations | `list(object)` | `[]` | no |

### Queues and Routing

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `queues` | List of queue configurations | `list(object)` | `[]` | no |
| `routing_profiles` | List of routing profile configurations | `list(object)` | `[]` | no |

### Security and Users

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `security_profiles` | List of security profile configurations | `list(object)` | `[]` | no |
| `users` | List of user configurations | `list(object)` | `[]` | no |
| `create_admin_user` | Create an admin user | `bool` | `false` | no |
| `admin_user` | Admin user configuration | `object` | see defaults | no |

### Phone Numbers and Contact Flows

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `phone_numbers` | Map of phone numbers to provision | `map(object)` | `{}` | no |
| `quick_connects` | Map of quick connect configurations | `map(object)` | `{}` | no |
| `contact_flows` | List of contact flow configurations | `list(object)` | `[]` | no |

### Integrations

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `lambda_functions` | Map of Lambda functions to associate | `map(object)` | `{}` | no |
| `lex_bots` | List of Lex bots to associate | `list(object)` | `[]` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `tags` | Tags to apply to all resources | `map(string)` | `{ ManagedBy = "terraform" }` | no |
| `instance_tags` | Additional tags for the instance | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The identifier of the Connect instance |
| `instance_arn` | Amazon Resource Name (ARN) of the instance |
| `instance_status` | The state of the instance |
| `instance_alias` | The alias of the Connect instance |
| `queue_ids` | Map of queue names to their IDs |
| `queue_arns` | Map of queue names to their ARNs |
| `routing_profile_ids` | Map of routing profile names to their IDs |
| `security_profile_ids` | Map of security profile names to their IDs |
| `user_ids` | Map of usernames to their user IDs |
| `phone_number_ids` | Map of phone number keys to their IDs |
| `phone_numbers` | Map of phone number keys to actual numbers |
| `contact_flow_ids` | Map of contact flow names to their IDs |
| `lambda_function_associations` | Map of Lambda function associations |
| `lex_bot_associations` | Map of Lex bot associations |
| `connect_summary` | Summary of the Connect configuration |

## Security Best Practices

1. **Identity Management**: Use SAML or AWS Directory Service for production environments
2. **Passwords**: Never hardcode passwords; use AWS Secrets Manager
3. **Security Profiles**: Follow principle of least privilege
4. **Phone Numbers**: Restrict outbound calling to necessary queues only
5. **Contact Flow Logs**: Always enable for production debugging
6. **Encryption**: Data is encrypted at rest and in transit by default
7. **IAM Roles**: Module creates IAM roles with least privilege
8. **IAM Policy**: Default uses AWS managed `AmazonConnect_FullAccess` policy. For production, consider using a custom policy with minimal required permissions:

```hcl
module "connect" {
  source = "./base_elements/connect_instance"
  
  instance_alias = "secure-contact-center"
  
  # Disable default managed policy
  connect_iam_policy_arn = ""
  
  # Define custom policy with least privilege
  # (Create custom policy separately and reference it)
}
```

### Admin User Creation

When creating an admin user (`create_admin_user = true`), note the following:

- **Security Profiles**: The module assigns default Admin security profiles from the Connect instance
- **Requirements**: Ensure the Connect instance is fully initialized before user creation
- **Routing Profile**: Admin user requires at least one routing profile to be defined in `routing_profiles`
- **Manual Fallback**: If admin user creation fails due to security profile issues, manually assign profiles in the Connect console

Example with admin user:

```hcl
module "connect" {
  source = "./base_elements/connect_instance"
  
  instance_alias = "my-contact-center"
  
  # Define at least one routing profile for admin user
  routing_profiles = [
    {
      name                        = "BasicProfile"
      default_outbound_queue_name = "BasicQueue"
      media_concurrencies = [
        { channel = "VOICE", concurrency = 1 }
      ]
    }
  ]
  
  # Enable admin user creation
  create_admin_user = true
  admin_user = {
    username   = "admin"
    email      = "admin@example.com"
    first_name = "Admin"
    last_name  = "User"
  }
}

## Contact Flow Development

### Using Inline JSON

```hcl
contact_flows = [
  {
    name    = "SimpleFlow"
    type    = "CONTACT_FLOW"
    content = jsonencode({
      Version = "2019-10-30"
      StartAction = "12345678-1234-1234-1234-123456789012"
      Actions = [
        # ... flow definition
      ]
    })
  }
]
```

### Using File-Based Configuration

```hcl
contact_flows = [
  {
    name     = "ComplexFlow"
    type     = "CONTACT_FLOW"
    filename = "./contact-flows/complex-flow.json"
  }
]
```

## Examples

See the `examples/` directory for complete working examples:

- **basic-instance**: Minimal Connect instance setup
- **full-contact-center**: Complete contact center with all features
- **lex-lambda-integration**: Integration with Lex bots and Lambda functions

## Module-Level vs Component-Level Operations

### Understanding Terraform Modules and Targets

This Connect instance is a **Terraform module**. When you use it, all `.tf` files in the module directory are loaded together. However, you can still target specific resources within the module.

**Key Concepts:**

1. **All `.tf` files are loaded**: Terraform reads all `.tf` files in the directory, regardless of their names
2. **File names are organizational**: Breaking code into `phone_numbers.tf`, `users.tf`, etc. is for readability
3. **Target specific resources**: Use `-target` to operate on specific resources defined in those files
4. **State is unified**: All resources share the same state file in S3

### Component Mapping

| Component | File | Resource Type | Target Flag Example |
|-----------|------|---------------|---------------------|
| Phone Numbers | phone_numbers.tf | `aws_connect_phone_number` | `-target=module.connect.aws_connect_phone_number.phone_numbers` |
| Users | users.tf | `aws_connect_user` | `-target=module.connect.aws_connect_user.users` |
| Hierarchy Groups | users.tf | `aws_connect_user_hierarchy_group` | `-target=module.connect.aws_connect_user_hierarchy_group.hierarchy_groups` |
| Security Profiles | security_profiles.tf | `aws_connect_security_profile` | `-target=module.connect.aws_connect_security_profile.security_profiles` |
| Routing Profiles | routing_profiles.tf | `aws_connect_routing_profile` | `-target=module.connect.aws_connect_routing_profile.routing_profiles` |
| Queues | queues.tf | `aws_connect_queue` | `-target=module.connect.aws_connect_queue.queues` |
| Contact Flows | contact_flows.tf | `aws_connect_contact_flow` | `-target=module.connect.aws_connect_contact_flow.contact_flows` |
| Quick Connects | quick_connects.tf | `aws_connect_quick_connect` | `-target=module.connect.aws_connect_quick_connect.quick_connects` |
| Hours of Operation | hours_of_operation.tf | `aws_connect_hours_of_operation` | `-target=module.connect.aws_connect_hours_of_operation.hours` |
| Lambda Functions | integrations.tf | `aws_connect_lambda_function_association` | `-target=module.connect.aws_connect_lambda_function_association.lambda_functions` |
| Lex Bots | integrations.tf | `aws_connect_bot_association` | `-target=module.connect.aws_connect_bot_association.lex_bots` |
| IAM Role | iam.tf | `aws_iam_role` | `-target=module.connect.aws_iam_role.connect_role` |
| CloudWatch Logs | logging.tf | `aws_cloudwatch_log_group` | `-target=module.connect.aws_cloudwatch_log_group.contact_flow_logs` |

### Example: Adding Only Phone Numbers to Existing Instance

```bash
# 1. Edit your terraform.tfvars to add phone numbers
cat >> terraform.tfvars <<EOF
phone_numbers = {
  new_support_line = {
    country_code = "GB"
    type         = "DID"
    description  = "New support line"
  }
}
EOF

# 2. Plan only phone number changes
terraform plan -target=module.connect.aws_connect_phone_number.phone_numbers

# 3. Apply only phone number changes
terraform apply -target=module.connect.aws_connect_phone_number.phone_numbers

# 4. Verify in state
terraform state list | grep phone_number

# 5. Verify in S3
aws s3 ls s3://my-terraform-state-bucket/connect-instance/terraform.tfstate --recursive
```

## Limitations

- Phone number availability varies by region
- Some features may require service quota increases
- Contact flow JSON format is specific to Connect API version
- User passwords only work with CONNECT_MANAGED identity management
- Targeted operations require understanding resource dependencies (e.g., users depend on routing/security profiles)

## Troubleshooting

### State Management Issues

#### State Lock Conflicts

If you get "Error acquiring the state lock":

```bash
# Check who has the lock
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"my-terraform-state-bucket/connect-instance/terraform.tfstate-md5"}}'

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

#### State Out of Sync

If Terraform state doesn't match reality:

```bash
# Refresh state from AWS
terraform refresh

# Or for specific resources
terraform refresh -target=module.connect.aws_connect_user.users

# Verify changes
terraform plan
```

#### Missing State File in S3

If state file is accidentally deleted:

```bash
# List versions (if versioning enabled)
aws s3api list-object-versions \
  --bucket my-terraform-state-bucket \
  --prefix connect-instance/terraform.tfstate

# Restore previous version
aws s3api copy-object \
  --bucket my-terraform-state-bucket \
  --copy-source my-terraform-state-bucket/connect-instance/terraform.tfstate?versionId=<version-id> \
  --key connect-instance/terraform.tfstate
```

#### State Drift Detection

```bash
# Generate drift report
terraform plan -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Changes detected
```

### Phone Number Provisioning Failures

If phone number provisioning fails:
- Check service quotas for your region
- Verify country code is supported in your region
- Ensure you have proper IAM permissions

### Contact Flow Errors

If contact flows fail to deploy:
- Validate JSON structure using Connect console
- Check that referenced resources (queues, Lambda, Lex) exist
- Review CloudWatch logs for detailed error messages

### User Creation Failures

If user creation fails:
- Ensure routing profiles and security profiles are created first
- Verify username is unique
- Check that email addresses are valid

### Targeted Apply Not Working

If `-target` doesn't work as expected:

```bash
# Ensure module path is correct
terraform state list

# Use exact resource address from state list
terraform apply -target='<exact-resource-address>'

# For resources with keys (like maps)
terraform apply -target='module.connect.aws_connect_user.users["john.doe"]'
```

## Contributing

When contributing to this module:
1. Follow Terraform coding standards
2. Update documentation for new features
3. Add examples for complex configurations
4. Test in multiple regions

## Resources

- [Amazon Connect Documentation](https://docs.aws.amazon.com/connect/)
- [Contact Flow JSON Reference](https://docs.aws.amazon.com/connect/latest/adminguide/contact-flow-language.html)
- [Terraform AWS Provider - Connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance)

## License

This module is maintained as part of the infrastructure-as-code standards.

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-02  
**Maintained By**: DevOps Team
