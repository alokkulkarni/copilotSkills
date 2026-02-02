# AWS Connect Instance Terraform Module

This Terraform module deploys and configures an Amazon Connect instance with full support for phone numbers, contact flows, queues, routing profiles, security profiles, users, and integrations with AWS Lambda and Amazon Lex.

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

## Limitations

- Phone number availability varies by region
- Some features may require service quota increases
- Contact flow JSON format is specific to Connect API version
- User passwords only work with CONNECT_MANAGED identity management

## Troubleshooting

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
